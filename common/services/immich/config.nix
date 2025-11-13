{ lib, config, ... }:
with lib;
{
  newVersionCheck = {
    enabled = false;
  };
  oauth = {
    enabled = true;
    buttonText = "Mit Authelia anmelden";
    clientId = custom.mkSecretPlaceholder config "oidc/immich/id" "immich";
    clientSecret = custom.mkSecretPlaceholder config "oidc/immich/secret" "immich";
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
