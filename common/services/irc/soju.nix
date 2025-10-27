{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.soju;
  subdomain = "irc";
  domain = "${subdomain}.${config.custom.services.caddy.domain}";
in
{
  options.custom.services.soju = {
    enable = custom.enableOption;

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
      hostName = domain;
      listen = [
        "ircs://:${toString cfg.ports.ircs}"
        "http+insecure://localhost:${toString cfg.ports.http}"
      ];
      acceptProxyIP = [ "0.0.0.0/0" ];
      tlsCertificate = "/var/lib/acme/${domain}/fullchain.pem";
      tlsCertificateKey = "/var/lib/acme/${domain}/key.pem";
      extraConfig = ''
        http-ingress https://${domain}
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
      soju-user-setup = {
        description = "Setup Soju users";
        after = [ "soju.service" ];
        wantedBy = [ "multi-user.target" ];
        script =
          let
            sojuctl = "${pkgs.soju}/bin/sojuctl -config ${config.services.soju.configFile}";
            userctl = "${sojuctl} user run ${username}";

            username = "\"$(cat ${config.sops.secrets."common/soju/user/username".path})\"";
            password = "\"$(cat ${config.sops.secrets."common/soju/user/password".path})\"";

            net = {
              name = "\"$(cat ${config.sops.secrets."common/soju/network/name".path})\"";
              host = "\"$(cat ${config.sops.secrets."common/soju/network/host".path})\"";
              username = "\"$(cat ${config.sops.secrets."common/soju/network/username".path})\"";
              password = "\"$(cat ${config.sops.secrets."common/soju/network/password".path})\"";
            };
          in
          ''
            #!/bin/sh

            # create user
            if ! ${sojuctl} user status ${username}; then
              ${sojuctl} user create -username ${username} -password ${password} -admin=true
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

    sops = {
      secrets = {
        "common/soju/user/username".owner = "soju";
        "common/soju/user/password".owner = "soju";

        "common/soju/network/name".owner = "soju";
        "common/soju/network/host".owner = "soju";
        "common/soju/network/username".owner = "soju";
        "common/soju/network/password".owner = "soju";
      };
    };

    custom.services.caddy.hosts = {
      soju = {
        inherit subdomain;
        target = ":${toString cfg.ports.http}";
      };
    };

    custom.system.persistence.config = {
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
}
