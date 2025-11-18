{ vars, ... }:
{
  allowLocalDeployment = true;
  targetHost = vars.hosts.pluto;
}
