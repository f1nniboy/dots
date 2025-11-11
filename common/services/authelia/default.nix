{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.authelia;

  name = "authelia-main";
  dn = custom.domainToDn vars.net.domain;
  oidcConfigFile = pkgs.writeTextFile {
    name = "oidc-clients.yaml";
    text = import ./oidc-config.nix {
      inherit lib config cfg;
    };
  };
in
{
  options.custom.services.authelia = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "auth";
    };

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
      description = "list of access control rules";
      example = [
        {
          domain = "example.com";
          policy = "two_factor";
          resources = [ "^/api/.*$" ];
          subject = [ "group:admin" ];
        }
      ];
    };

    clients = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
            };

            makeSecrets = mkOption {
              type = types.bool;
              description = "whether secrets used by the client should be created";
              default = false;
            };

            policy = mkOption {
              type = types.str;
              default = "one_factor";
            };

            public = mkOption {
              type = types.bool;
              default = false;
            };

            requirePkce = mkOption {
              type = types.bool;
              default = true;
            };

            scopes = mkOption {
              type = types.listOf types.str;
              default = [
                "openid"
                "email"
                "profile"
                "groups"
              ];
            };

            redirectUris = mkOption {
              type = types.listOf types.str;
            };

            responseTypes = mkOption {
              type = types.listOf types.str;
              default = [ "code" ];
            };

            grantTypes = mkOption {
              type = types.listOf types.str;
              default = [ "authorization_code" ];
            };

            accessTokenAlg = mkOption {
              type = types.str;
              default = "none";
            };

            userinfoAlg = mkOption {
              type = types.str;
              default = "none";
            };

            tokenAuthMethod = mkOption {
              type = types.str;
              default = "client_secret_basic";
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkMerge [
    # regardless of authelia being enabled, create the requested secrets
    {
      custom.system.sops.secrets =
        let
          mkClientSecrets = id: client: [
            # secrets to be used by the client
            (mkIf client.makeSecrets {
              path = "oidc/${id}/secret";
              owner = id;
              source = "common";
            })
            (mkIf client.makeSecrets {
              path = "oidc/${id}/id";
              owner = id;
              source = "common";
            })

            # secrets to be used by authelia
            (mkIf cfg.enable {
              path = "oidc/${id}/secret-hash";
              owner = name;
              source = "common";
            })
            (mkIf cfg.enable {
              path = "oidc/${id}/id";
              owner = name;
              source = "common";
            })
          ];
          clientSecretLists = mapAttrsToList mkClientSecrets cfg.clients;
        in
        concatLists clientSecretLists;
    }
    (mkIf cfg.enable {
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
                  address = "ldap://${vars.net.services.lldap}:${toString config.custom.services.lldap.ports.ldap}";
                  implementation = "lldap";
                  base_dn = dn;
                  user = "uid=bind:authelia,ou=people,${dn}";
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
                    authelia_url = "https://${custom.mkServiceDomain config "authelia"}";

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
                # ref: https://www.authelia.com/integration/openid-connect/openid-connect-1.0-claims/#restore-functionality-prior-to-claims-parameter
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
            # templates don't work correctly when parsed from nix,
            # so we have to do oidc clients in a separate file
            settingsFiles = [ oidcConfigFile ];
            secrets =
              let
                mkSecret = path: custom.mkSecretPath config "authelia/${path}" name;
              in
              {
                jwtSecretFile = mkSecret "jwt-secret";
                storageEncryptionKeyFile = mkSecret "storage-encryption-key";
                sessionSecretFile = mkSecret "session-secret";
                oidcIssuerPrivateKeyFile = mkSecret "jwks";
                oidcHmacSecretFile = mkSecret "hmac-secret";
              };
          };
        };
      };

      custom = {
        system = {
          sops.secrets = [
            {
              path = "authelia/jwt-secret";
              owner = name;
            }
            {
              path = "authelia/storage-encryption-key";
              owner = name;
            }
            {
              path = "authelia/session-secret";
              owner = name;
            }
            {
              path = "authelia/hmac-secret";
              owner = name;
            }
            {
              path = "authelia/jwks";
              owner = name;
            }
          ];
        };
        services = {
          caddy.hosts = {
            authelia = {
              target = ":${toString cfg.port}";
              enableLogging = true;
            };
          };
          postgresql.users = [ name ];
          redis.servers = [ name ];
        };
      };
    })
  ];
}
