{ vars, ... }:
builtins.toJSON {
  global_environment_environment = {
    urls = {
      base = "https://vault.${vars.net.domain}";
    };
  };
  global_loginEmail_storedEmail = vars.user.email;
}
