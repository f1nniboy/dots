{ vars, ... }:
{
  targetHost = vars.net.hosts.vps;
  tags = [ "server" ];
}
