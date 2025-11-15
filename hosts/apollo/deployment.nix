{ vars, ... }:
{
  targetHost = vars.net.hosts.apollo;
  tags = [ "server" ];
}
