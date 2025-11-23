{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.docker;
in
{
  options.custom.services.docker = {
    enable = custom.enableOption;
  };

  imports = [
    inputs.arion.nixosModules.arion
  ];

  config = mkIf cfg.enable {
    virtualisation = {
      docker = {
        enable = true;
        autoPrune.enable = true;

        daemon.settings = mkIf (config.custom.system.firewall.backend == "nftables") {
          iptables = false;
          ip6tables = false;
          ipv6 = false;

          # TODO: way too hacky
          dns = [
            "8.8.8.8"
            "172.17.0.1"
          ];
        };
      };
      oci-containers.backend = "docker";
      arion.backend = "docker";
    };

    custom.system = {
      firewall.rules = mkIf (config.custom.system.firewall.backend == "nftables") [
        # ref: https://www.schwitzd.me/posts/from-iptables-to-nftables-with-docker/
        # only supports default docker0 bridge with default IP range
        # TODO: switch to native nftables support once v29 releases
        #       https://github.com/NixOS/nixpkgs/pull/458995
        ''
          define docker_if = "docker0"
          define wan_if = "eno1"  # Change this to your real external interface (e.g. wlan0)

          table inet filter {
            chain input {
              type filter hook input priority 0; policy drop

              # Allow loopback traffic
              iifname lo accept

              # Accept established and related connections
              ct state established,related accept

              # Allow ICMP (v4 and v6)
              ip protocol icmp accept
              ip6 nexthdr ipv6-icmp accept

              # Allow DHCPv6 client replies
              udp dport 546 udp sport 547 accept

              # Allow limited incoming multicast (IPv4 & IPv6)
              ip daddr 224.0.0.0/4 accept
              ip6 daddr ff00::/8 accept
            }

            chain forward {
              type filter hook forward priority 0; policy drop

              # Allow containers to forward to WAN
              iifname $docker_if oifname $wan_if accept
              # Allow return traffic
              ct state established,related accept
            }

            chain output {
              type filter hook output priority 0; policy accept
            }
          }

          table ip nat {
            chain postrouting {
              type nat hook postrouting priority 100; policy accept

              # Masquerade container traffic going to internet
              oifname $wan_if ip saddr 172.17.0.0/16 masquerade
            }
          }
        ''
      ];
      user.extraGroups = [ "docker" ];
      persistence.config = {
        directories = [ "/var/lib/docker" ];
      };
    };
  };
}
