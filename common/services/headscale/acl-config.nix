{ config, lib, ... }:
with lib;
let
  mkUserSecret = key: (custom.mkSecretPlaceholder config "tailscale/acl/users/${key}" "headscale");

  users = {
    a = mkUserSecret "a";
    b = mkUserSecret "b";
  };
in
{
  groups =
    let
      inherit (config.custom.cfg.user) nick;
    in
    {
      "group:admin" = [ "${nick}@" ];
      "group:family" = [
        "${nick}@"
        users.a
        users.b
      ];
    };

  # configure what tags can be used by which users
  tagOwners = {
    # machines designated as servers
    "tag:server" = [ "group:admin" ];

    # the machine running Wolf (game streaming)
    "tag:gaming" = [ "group:admin" ];

    # the server running all core services, like headscale & dns
    "tag:root" = [ "group:admin" ];

    # machines running ollama
    "tag:ollama" = [ "group:admin" ];
  };

  acls = [
    # admins can access all servers by default
    {
      action = "accept";
      src = [ "*" ];
      dst = [ "*:*" ];
    }

    # family can access HTTP of all servers
    {
      action = "accept";
      src = [ "group:family" ];
      dst = [ "tag:server:80,443" ];
    }

    # all devices can access DNS of the root server (which hosts headscale)
    # to make `*.${domains.local}` domains work
    {
      action = "accept";
      src = [ "*" ];
      dst = [ "tag:root:53" ];
    }

    # family can access all Wolf ports of gaming servers
    {
      action = "accept";
      src = [ "group:family" ];
      dst = [ "tag:gaming:47984,47989,47999,48010,48100,48200" ];
    }

    # the root server (which runs the CA authority) can access HTTP ports on all devices
    # required to create certificates
    {
      action = "accept";
      src = [ "tag:root" ];
      dst = [ "*:80,443" ];
    }

    # server at home can access all machines running ollama
    {
      action = "accept";
      src = [ "apollo" ];
      dst = [ "tag:ollama:80,443,11434" ];
    }
  ];

  inherit (config.custom.cfg) hosts;
}
