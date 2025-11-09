{ vars, ... }:
{
  targetHost = vars.net.hosts.lab;
  tags = [ "server" ];
}
