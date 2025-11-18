{ lib, ... }:
with lib;
rec {
  # pre-defined mkEnableOption without a description
  enableOption = mkOption {
    default = false;
    type = types.bool;
  };

  # "example.com" -> "dc=example,dc=com"
  domainToDn =
    domain: concatMapStringsSep "," (part: "dc=${part}") (filter (p: p != "") (splitString "." domain));

  mkServiceSub = config: name: config.custom.cfg.services."${name}".sub;

  mkServiceDomain =
    config: name:
    let
      svc = config.custom.cfg.services."${name}";
    in
    "${if svc.sub != null then "${svc.sub}." else ""}${
      if svc.public then config.custom.cfg.domains.public else config.custom.cfg.domains.local
    }";

  mkSecretString = path: service: "${service}-${path}";
  mkSecretPlaceholder =
    config: path: service:
    config.sops.placeholder."${mkSecretString path service}";
  mkSecretPath =
    config: path: service:
    config.sops.secrets."${mkSecretString path service}".path;

  mkDockerUser =
    config: name:
    "${toString config.users.users."${name}".uid}:${toString config.users.groups."${name}".gid}";

  mkDockerImage = vars: name: "${name}:${vars.docker.images."${name}"}";
}
