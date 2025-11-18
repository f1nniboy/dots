{ vars, ... }:
{
  targetHost = vars.hosts.jupiter;
  tags = [ "server" ];
}
