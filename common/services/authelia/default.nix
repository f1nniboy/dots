{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.authelia;

  dn = custom.domainToDn config.custom.cfg.domains.public;
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

    name = mkOption {
      type = types.str;
      default = "authelia-main";
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
              owner = cfg.name;
              source = "common";
            })
            (mkIf cfg.enable {
              path = "oidc/${id}/id";
              owner = cfg.name;
              source = "common";
            })
          ];
          clientSecretLists = mapAttrsToList mkClientSecrets cfg.clients;
        in
        concatLists clientSecretLists;
    }
    (mkIf cfg.enable {
      systemd.services.${cfg.name} =
        let
          deps = [
            "lldap.service"
            "postgresql.service"
            "redis-${cfg.name}.service"
          ];
        in
        {
          requires = deps;
          after = deps;

          serviceConfig.Environment = "X_AUTHELIA_CONFIG_FILTERS=template";
        };

      users.users.${cfg.name} = {
        extraGroups = [
          "postgres"
          "redis-${cfg.name}"
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
                  base_dn = dn;
                  user = "uid=bind:authelia,ou=people,${dn}";
                  password = "binduser";
                  # allow users to sign in with username, e-mail or first name
                  users_filter = "(&(|({username_attribute}={input})(mail={input})(firstName={input}))(objectClass=person))";
                };
              };
              session = {
                redis = {
                  host = config.services.redis.servers.${cfg.name}.unixSocket;
                };
                cookies = [
                  # public
                  {
                    domain = config.custom.cfg.domains.public;
                    authelia_url = "https://${custom.mkServiceDomain config "authelia-public"}";

                    inactivity = "1M";
                    expiration = "3M";
                    remember_me = "1y";
                  }

                  # local
                  {
                    domain = config.custom.cfg.domains.local;
                    authelia_url = "https://${custom.mkServiceDomain config "authelia"}";

                    inactivity = "1M";
                    expiration = "3M";
                    remember_me = "1y";
                  }
                ];
              };
              storage.postgres = {
                address = "unix:///var/run/postgresql";
                database = cfg.name;
                username = cfg.name;
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
                mkSecret = path: custom.mkSecretPath config "authelia/${path}" cfg.name;
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
          sops.secrets =
            let
              mkSecret = path: {
                path = "authelia/${path}";
                owner = cfg.name;
              };
            in
            map mkSecret [
              "jwt-secret"
              "storage-encryption-key"
              "session-secret"
              "hmac-secret"
              "jwks"
            ];
        };
        services = {
          caddy.hosts = {
            # TODO: kind of stupid solution
            # https://github.com/authelia/authelia/discussions/7439 is not very helpful
            authelia-public = {
              target = ":${toString cfg.port}";
              ca = "public";
            };
            authelia.target = ":${toString cfg.port}";
          };
          postgresql.users = [ cfg.name ];
          redis.servers = [ cfg.name ];
        };
      };
    })
  ];
}
