{
  vars,
  ...
}:
{
  custom = {
    presets = {
      base.enable = true;
    };

    services = {
      headscale.enable = true;
      tailscale.enable = true;

      openssh.enable = true;
      postgresql.enable = true;
      redis.enable = true;

      caddy = {
        enable = true;
        inherit (vars.net) domain;
      };

      authelia.enable = true;
      lldap.enable = true;

      blog.enable = true;

      # make secrets of services using oidc accessible
      immich.forOidc = true;
      paperless.forOidc = true;
      miniflux.forOidc = true;
      forgejo.forOidc = true;
      open-webui.forOidc = true;
    };

    system = {
      remoteUnlock.enable = true;
      boot.legacy = true;
    };
  };
}
