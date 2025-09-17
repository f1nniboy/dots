{ config, ... }:
builtins.toJSON {
  stateVersion = 72;
  global_applicationId_appId = "0439add8-2283-4f96-9db0-f9143d22cc1f";
  global_config_byServer = {
    "https://vault.f1nn.space/api" = {
      featureStates = {
        duo-redirect = true;
        email-verification = true;
        enable-pm-flight-recorder = true;
        mobile-error-reporting = true;
        unauth-ui-refresh = true;
      };
      version = "2025.6.0";
      gitHash = null;
      server = {
        name = "Vaultwarden";
        url = "https://github.com/dani-garcia/vaultwarden";
      };
      utcDate = "2025-09-17T16:05:12.597Z";
      environment = {
        cloudRegion = null;
        vault = "http://localhost";
        api = "http://localhost/api";
        identity = "http://localhost/identity";
        notifications = "http://localhost/notifications";
        sso = "";
      };
      push = {
        pushTechnology = 0;
        vapidPublicKey = null;
      };
      settings = {
        disableUserRegistration = false;
      };
    };
  };
  global_loginEmail_storedEmail = config.custom.system.user.email;
  global_environment_environment = {
    region = "Self-hosted";
    urls = {
      base = "https://vault.f1nn.space";
      api = null;
      identity = null;
      webVault = null;
      icons = null;
      notifications = null;
      events = null;
      keyConnector = null;
    };
  };
  global_account_accounts = {
    "00a527c1-fddc-4eea-bca7-12342407578c" = {
      name = config.custom.system.user.realName;
      email = config.custom.system.user.email;
      emailVerified = true;
    };
  };
  user_00a527c1-fddc-4eea-bca7-12342407578c_environment_environment = {
    region = "Self-hosted";
    urls = {
      base = "https://vault.f1nn.space";
      api = null;
      identity = null;
      webVault = null;
      icons = null;
      notifications = null;
      events = null;
      keyConnector = null;
      scim = null;
    };
  };
  global_account_activeAccountId = "00a527c1-fddc-4eea-bca7-12342407578c";
}