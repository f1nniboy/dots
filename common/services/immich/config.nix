{ lib, config, ... }:
with lib;
builtins.toJSON {
  newVersionCheck = {
    enabled = false;
  };
  oauth = {
    enabled = true;
    buttonText = "Mit Authelia anmelden";
    clientId = config.sops.placeholder."${config.networking.hostName}/oidc/immich/id";
    clientSecret = config.sops.placeholder."${config.networking.hostName}/oidc/immich/secret";
    issuerUrl = "https://${custom.mkServiceDomain config "authelia"}";
    tokenEndpointAuthMethod = "client_secret_basic";
  };
  passwordLogin = {
    enabled = false;
  };
  machineLearning = {
    clip = {
      enabled = true;
      modelName = "ViT-B-16-SigLIP2__webli";
    };
    duplicateDetection = {
      enabled = true;
      maxDistance = 0.04;
    };
  };
  server = {
    externalDomain = "https://${custom.mkServiceDomain config "immich"}";
  };
  storageTemplate = {
    enabled = true;
    template = "{{y}}/{{MM}}/{{dd}}/{{filename}}";
  };
}
