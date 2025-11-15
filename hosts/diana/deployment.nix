{ vars, ... }:
{
  allowLocalDeployment = true;
  targetHost = vars.net.hosts.diana;
  targetUser = "me";
}
