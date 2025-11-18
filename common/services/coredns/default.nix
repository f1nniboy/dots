{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.services.coredns;

  # map a service to a simple /etc/hosts entry, or `null` if the service is public
  serviceToHostEntry =
    _: svc:
    if svc.public == true || svc.sub == null then
      null
    else
      let
        ip = config.custom.cfg.hosts.${svc.host};
        fqdn = "${svc.sub}.${config.custom.cfg.domains.local}";
      in
      "${ip} ${fqdn}";

  entries =
    # extract all non-null generated lines
    lib.filter (x: x != null) (lib.mapAttrsToList serviceToHostEntry config.custom.cfg.services);

  hostsFile = pkgs.writeTextFile {
    name = "hosts";
    text = concatStringsSep "\n" entries + "\n";
  };
in
{
  options.custom.services.coredns = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    services.coredns = {
      enable = true;
      config = ''
        . {
          hosts ${hostsFile}
        }
      '';
    };
  };
}
