{ ... }:
{
  custom = {
    presets = {
      base.enable = true;
    };

    services = {
      headscale.enable = true;
      tailscale = {
        enable = true;
        tags = [
          "server"
          "root"
        ];
      };
      coredns.enable = true;

      openssh.enable = true;
      postgresql.enable = true;
      redis.enable = true;

      caddy = {
        enable = true;
      };
      step-ca = {
        enable = true;
        role = "server";
      };

      authelia.enable = true;
      lldap.enable = true;

      blog.enable = true;

      # apply authelia configurations of each service
      immich.forAuth = true;
      paperless.forAuth = true;
      miniflux.forAuth = true;
      forgejo.forAuth = true;
      open-webui.forAuth = true;
      karakeep.forAuth = true;
    };

    system = {
      remoteUnlock.enable = true;
      boot.legacy = true;
    };
  };
}
