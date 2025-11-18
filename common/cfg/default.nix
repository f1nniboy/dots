{
  lib,
  vars,
  ...
}:
with lib;
{
  options.custom.cfg = {
    user = mkOption {
      type = types.submodule {
        options = {
          fullName = mkOption {
            type = types.str;
          };
          nick = mkOption {
            type = types.str;
          };
          email = mkOption {
            type = types.str;
          };
        };
      };
    };

    ssh = mkOption {
      type = types.submodule {
        options = {
          authorizedKeys = mkOption {
            type = types.listOf types.str;
          };
        };
      };
    };

    domains = mkOption {
      type = types.submodule {
        options = {
          public = mkOption {
            type = types.str;
          };
          local = mkOption {
            type = types.str;
          };
        };
      };
    };

    hosts = mkOption {
      type = types.attrsOf types.str;
    };

    services = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            sub = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            host = mkOption {
              type = types.str;
              default = "apollo";
            };
            public = mkOption {
              type = types.bool;
              default = false;
            };
          };
        }
      );
    };

    docker = mkOption {
      type = types.submodule {
        options = {
          images = mkOption {
            type = types.attrsOf types.str;
          };
        };
      };
    };
  };

  config = {
    custom.cfg = vars;
  };
}
