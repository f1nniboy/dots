{ config, lib, ... }:
with lib;
let
  cfg = config.custom.services.redis;
in
{
  options.custom.services.redis = {
    enable = custom.enableOption;
    servers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of Redis server names to configure";
    };
  };

  config = mkIf cfg.enable {
    services.redis.servers = listToAttrs (
      map (name: {
        inherit name;
        value = {
          enable = true;
        };
      }) cfg.servers
    );
  };
}
