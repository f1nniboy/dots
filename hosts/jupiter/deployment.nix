{ vars, ... }:
{
  targetHost = vars.net.hosts.jupiter;
  tags = [ "server" ];
}
