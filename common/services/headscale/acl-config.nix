{
  config,
  lib,
  vars,
  ...
}:
with lib;
let
  mkUserSecret = key: (custom.mkSecretPlaceholder config "tailscale/acl/users/${key}" "headscale");

  users = {
    a = mkUserSecret "a";
    b = mkUserSecret "b";
  };
in
{
  groups = {
    "group:admin" = [ "finn@" ];
    "group:family" = [
      "finn@"
      users.a
      users.b
    ];
  };

  # configure what tags can be used by users (by group)
  tagOwners = {
    "tag:server" = [ "group:admin" ];
  };

  acls = [
    # admins can access all ports of all servers
    {
      action = "accept";
      src = [ "group:admin" ];
      dst = [ "tag:server:*" ];
    }

    # family can only access HTTP of server at home
    {
      action = "accept";
      src = [ "group:family" ];
      dst = [ "apollo:80,443" ];
    }

    # family can access all Wolf streaming ports
    {
      action = "accept";
      src = [ "group:family" ];
      dst = [ "diana:47984,47989,47999,48010,48100,48200" ];
    }
  ];

  hosts = {
    inherit (vars.net.hosts) apollo jupiter diana;
  };
}
