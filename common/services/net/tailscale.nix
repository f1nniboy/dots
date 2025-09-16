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
    enable = mkEnableOption "Tailscape VPN";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.jq
      pkgs.tailscale
    ];

    services = {
      tailscale.enable = true;
    };

    sops.secrets."common/tailscale/auth-key" = { };

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
          --authkey=$(cat "${config.sops.secrets."common/tailscale/auth-key".path}") \
          --operator=${config.custom.system.user.name}
      '';
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose"; # TODO: check if this breaks docker connectivity between containers
    };

    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/tailscale" ];
    };
  };
}
