{ vars, ... }:
builtins.toJSON {
  global_environment_environment = {
    urls = {
      base = "https://vault.${vars.lab.domain}";
    };
  };
  global_loginEmail_storedEmail = vars.user.email;
}
