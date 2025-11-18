{ vars, ... }:
{
  allowLocalDeployment = true;
  targetHost = vars.hosts.diana;
  targetUser = "me";
}
