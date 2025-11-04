{ lib, ... }:
with lib;
rec {
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
