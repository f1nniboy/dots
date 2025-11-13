{ vars, ... }:
{
  allowLocalDeployment = true;
  targetHost = vars.net.hosts.desktop;
  targetUser = "me";
}
