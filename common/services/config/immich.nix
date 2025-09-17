{ config, ... }:
builtins.toJSON {
  newVersionCheck = {
    enabled = false;
  };
  oauth = {
    enabled = true;
    buttonText = "Mit Authelia anmelden";
    clientId = config.sops.placeholder."${config.networking.hostName}/oidc/immich/id";
    clientSecret = config.sops.placeholder."${config.networking.hostName}/oidc/immich/secret";
    issuerUrl = "https://auth.${config.custom.services.caddy.domain}";
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
    externalDomain = "https://${config.custom.services.caddy.hosts.immich.subdomain}.${config.custom.services.caddy.domain}";
  };
  storageTemplate = {
    enabled = true;
    template = "{{y}}/{{MM}}/{{dd}}/{{filename}}";
  };
}