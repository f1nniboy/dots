{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.tailscale;
in
{
  options.custom.services.tailscale = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.jq
      pkgs.tailscale
    ];

    services = {
      tailscale.enable = true;
    };

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [
        "network-pre.target"
        "tailscale.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";

      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        [ "$status" != "NeedsLogin" ] && exit 0

        # otherwise authenticate with tailscale
        # timeout after 10 seconds to avoid hanging the boot process
        ${coreutils}/bin/timeout 10 ${tailscale}/bin/tailscale up \
          --authkey=$(cat "${custom.mkSecretPath config "tailscale/auth-key" "root"}") \
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
