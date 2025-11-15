{ vars, ... }:
{
  allowLocalDeployment = true;
  targetHost = vars.net.hosts.pluto;
}
