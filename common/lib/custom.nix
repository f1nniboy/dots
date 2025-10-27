{ lib, ... }:
with lib;
{
  # pre-defined mkEnableOption without a description
  enableOption = mkOption {
    default = false;
    type = types.bool;
  };
}
