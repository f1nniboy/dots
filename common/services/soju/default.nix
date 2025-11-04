{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
with lib;
let
  cfg = config.custom.services.soju;
  serviceDomain = custom.mkServiceDomain config "soju";
in
{
  options.custom.services.soju = {
    enable = custom.enableOption;

    subdomain = mkOption {
      type = types.str;
      default = "irc";
    };

    ports = mkOption {
      type = types.submodule {
        options = {
          ircs = mkOption {
            type = types.port;
            default = 6697;
          };
          http = mkOption {
            type = types.port;
            default = 6680;
          };
        };
      };
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users = {
      users.soju = {
        isSystemUser = true;
        group = "soju";
      };
      groups.soju = { };
    };

    services.soju = {
      enable = true;
      hostName = serviceDomain;
      listen = [
        "ircs://:${toString cfg.ports.ircs}"
        "http+insecure://localhost:${toString cfg.ports.http}"
      ];
      acceptProxyIP = [ "0.0.0.0/0" ];
      tlsCertificate = "/var/lib/acme/${serviceDomain}/fullchain.pem";
      tlsCertificateKey = "/var/lib/acme/${serviceDomain}/key.pem";
      extraConfig = ''
        http-ingress https://${serviceDomain}
        file-upload http http://127.0.0.1:${toString config.custom.services.convoyeur.port}/upload
      '';
    };

    systemd.services = {
      soju = {
        serviceConfig = {
          DynamicUser = mkForce false;
          User = mkForce "soju";
          Group = mkForce "soju";
        };
      };
      # TODO: doesn't work reliably (few secs timeout to wait for soju?)
      soju-user-setup = {
        description = "Setup Soju users";
        after = [ "soju.service" ];
        wantedBy = [ "multi-user.target" ];
        script =
          let
            mkSecretCat = path: "\"$(cat ${custom.mkSecretPath config "soju/${path}" "soju"})\"";

            sojuctl = "${pkgs.soju}/bin/sojuctl -config ${config.services.soju.configFile}";
            userctl = "${sojuctl} user run ${account.username}";

            account = {
              username = vars.user.fullName;
              password = mkSecretCat "user/password";
            };

            net = {
              name = mkSecretCat "network/name";
              host = mkSecretCat "network/host";
              username = mkSecretCat "network/username";
              password = mkSecretCat "network/password";
            };
          in
          ''
            #!/bin/sh

            # create user
            if ! ${sojuctl} user status ${account.username}; then
              ${sojuctl} user create -username ${account.username} -password ${account.password} -admin=true
            fi

            # create network
            if ! ${userctl} network status | grep -q ${net.name}; then
              ${userctl} network create -name ${net.name} -addr ${net.host} -nick ${net.username} -pass ${net.password}
            fi
          '';
        serviceConfig = {
          Type = "oneshot";
          User = "soju";
          Group = "soju";
        };
      };
    };

    custom = {
      system = {
        sops.secrets = [
          {
            path = "soju/user/password";
            owner = "soju";
            source = "common";
          }
          {
            path = "soju/network/name";
            owner = "soju";
          }
          {
            path = "soju/network/host";
            owner = "soju";
          }
          {
            path = "soju/network/username";
            owner = "soju";
          }
          {
            path = "soju/network/password";
            owner = "soju";
          }
        ];
        persistence.config = {
          directories = [
            {
              directory = "/var/lib/soju";
              user = "soju";
              group = "soju";
              mode = "0700";
            }
          ];
        };
      };
      services = {
        caddy.hosts = {
          soju.target = ":${toString cfg.ports.http}";
        };
        acme.domains = {
          "${serviceDomain}" = {
            group = "soju";
          };
        };
      };
    };
  };
}
