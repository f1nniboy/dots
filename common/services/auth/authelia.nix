{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.authelia;
  name = "authelia-main";
in
{
  options.custom.services.authelia = {
    enable = custom.enableOption;

    port = mkOption {
      type = types.port;
      default = 9091;
    };

    rules = mkOption {
      type = types.listOf (
        types.attrsOf (
          types.oneOf [
            types.str
            (types.listOf types.str)
          ]
        )
      );
      default = [ ];
      description = "List of access control rules for Authelia";
      example = [
        {
          domain = "example.com";
          policy = "two_factor";
          resources = [ "^/api/.*$" ];
          subject = [ "group:admin" ];
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "${config.networking.hostName}/authelia/jwt-secret".owner = name;
      "${config.networking.hostName}/authelia/storage-encryption-key".owner = name;
      "${config.networking.hostName}/authelia/session-secret".owner = name;
      "${config.networking.hostName}/authelia/hmac-secret".owner = name;
      "${config.networking.hostName}/authelia/jwks".owner = name;
    };

    systemd.services.${name} =
      let
        deps = [
          "lldap.service"
          "postgresql.service"
          "redis-${name}.service"
        ];
      in
      {
        requires = deps;
        after = deps;

        serviceConfig.Environment = "X_AUTHELIA_CONFIG_FILTERS=template";
      };

    users.users.${name} = {
      extraGroups = [
        "postgres"
        "redis-${name}"
      ];
    };

    services = {
      authelia = {
        instances.main = {
          enable = true;
          settings = {
            server = {
              address = "tcp://127.0.0.1:${toString cfg.port}";
            };
            theme = "dark";
            authentication_backend = {
              password_change.disable = true;
              password_reset.disable = true;
              ldap = {
                address = "ldap://localhost:${toString config.custom.services.lldap.ports.ldap}";
                implementation = "lldap";
                base_dn = "dc=f1nn,dc=space";
                user = "uid=bind,ou=people,dc=f1nn,dc=space";
                password = "binduser";
                # allow users to sign in with username, e-mail or first name
                users_filter = "(&(|({username_attribute}={input})(mail={input})(firstName={input}))(objectClass=person))";
              };
            };
            session = {
              redis = {
                host = config.services.redis.servers.${name}.unixSocket;
              };
              cookies = [
                {
                  inherit (config.custom.services.caddy) domain;
                  authelia_url = "https://auth.${config.custom.services.caddy.domain}";

                  # the period of time the user can be inactive for before the session is destroyed
                  inactivity = "1M";
                  # the period of time before the cookie expires and the session is destroyed
                  expiration = "3M";
                  # the period of time before the cookie expires and the session is destroyed,
                  # when the remember me box is checked
                  remember_me = "1y";
                }
              ];
            };
            storage.postgres = {
              address = "unix:///var/run/postgresql";
              database = name;
              username = name;
              password = "";
            };
            notifier.filesystem = {
              filename = "/tmp/authelia-notification.txt";
            };
            access_control = {
              default_policy = "one_factor";
              inherit (cfg) rules;
            };
            identity_providers.oidc = {
              # https://www.authelia.com/integration/openid-connect/openid-connect-1.0-claims/#restore-functionality-prior-to-claims-parameter
              claims_policies = {
                karakeep.id_token = [ "email" ];
              };
              cors = {
                endpoints = [ "token" ];
                allowed_origins_from_client_redirect_uris = true;
              };
              authorization_policies.default = {
                default_policy = "one_factor";
                rules = [
                  {
                    policy = "deny";
                    subject = "group:lldap_strict_readonly";
                  }
                ];
              };
            };
          };
          # templates don't work correctly when parsed from nix
          settingsFiles = [ ./oidc-clients.yaml ];
          secrets = with config.sops; {
            jwtSecretFile = secrets."${config.networking.hostName}/authelia/jwt-secret".path;
            storageEncryptionKeyFile =
              secrets."${config.networking.hostName}/authelia/storage-encryption-key".path;
            sessionSecretFile = secrets."${config.networking.hostName}/authelia/session-secret".path;
            oidcIssuerPrivateKeyFile = secrets."${config.networking.hostName}/authelia/jwks".path;
            oidcHmacSecretFile = secrets."${config.networking.hostName}/authelia/hmac-secret".path;
          };
        };
      };
      caddy = {
        # snippet that can be imported to enable authelia in front of a service
        # ref: https://www.authelia.com/integration/proxies/caddy/#subdomain
        extraConfig = ''
          (auth) {
              forward_auth :${toString cfg.port} {
                  uri /api/authz/forward-auth
                  copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
              }
          }
        '';
      };
    };

    custom.services = {
      caddy.hosts = {
        authelia = {
          subdomain = "auth";
          target = ":${toString cfg.port}";
        };
      };
      postgresql.users = [ name ];
      redis.servers = [ name ];
    };
  };
}
