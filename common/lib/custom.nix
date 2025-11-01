{ lib, ... }:
with lib;
{
  # pre-defined mkEnableOption without a description
  enableOption = mkOption {
    default = false;
    type = types.bool;
  };

  # "f1nn.space" -> "dc=f1nn,dc=space"
  domainToDn =
    domain:
    lib.concatMapStringsSep "," (part: "dc=${part}") (
      lib.filter (p: p != "") (lib.splitString "." domain)
    );

  mkServiceDomain =
    config: name: "${config.custom.services.${name}.subdomain}.${config.custom.services.caddy.domain}";
}
