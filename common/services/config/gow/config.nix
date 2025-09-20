{ config, inputs, ... }:
with inputs.nix-std; toTOML {
  config_version = 5;
  hostname = "Wolf";
  uuid = config.custom.services.gow.id;
}