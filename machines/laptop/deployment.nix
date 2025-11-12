{ vars, ... }:
{
  allowLocalDeployment = true;
  targetHost = vars.net.hosts.laptop;
}
