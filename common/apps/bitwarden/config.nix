{
  lib,
  config,
  vars,
  ...
}:
with lib;
builtins.toJSON {
  global_environment_environment = {
    urls = {
      base = "https://${custom.mkServiceDomain config "vaultwarden"}";
    };
  };
  global_loginEmail_storedEmail = vars.user.email;
}
