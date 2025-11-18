{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.tailscale;
  tagString = builtins.concatStringsSep "," (map (tag: "tag:${tag}") cfg.tags);
in
{
  options.custom.services.tailscale = {
    enable = custom.enableOption;

    ip = mkOption {
      type = types.str;
      default = config.custom.cfg.hosts."${config.networking.hostName}";
    };

    loginServer = mkOption {
      type = types.str;
      default = "https://${custom.mkServiceDomain config "headscale"}";
    };

    tags = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.tailscale
    ];

    services = {
      tailscale.enable = true;
    };

    systemd.services.tailscale-autoconnect =
      let
        # make sure tailscale is running before trying to connect
        deps = [
          "network-pre.target"
          "tailscale.service"
        ];
      in
      {
        wantedBy = [ "multi-user.target" ];
        after = deps;
        wants = deps;

        serviceConfig.Type = "oneshot";

        script = with pkgs; ''
          # wait for tailscaled to settle
          sleep 3

          # otherwise authenticate with tailscale
          # timeout after a while to avoid hanging the boot process
          ${coreutils}/bin/timeout 15 ${tailscale}/bin/tailscale up \
            --authkey=file:${custom.mkSecretPath config "tailscale/auth-key" "root"} \
            --login-server="${cfg.loginServer}" \
            --hostname="${config.networking.hostName}" \
            --advertise-tags="${tagString}" \
            --operator=${config.custom.system.user.name}
        '';
      };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose";
    };

    custom.system = {
      sops.secrets = [
        {
          path = "tailscale/auth-key";
          source = "common";
        }
      ];
      persistence.config = {
        directories = [ "/var/lib/tailscale" ];
      };
    };
  };
}
