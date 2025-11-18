{ vars, ... }:
{
  targetHost = vars.hosts.apollo;
  tags = [ "server" ];
}
