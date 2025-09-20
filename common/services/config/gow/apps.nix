[
  {
    title = "Steam";
    image = "ghcr.io/games-on-whales/steam:edge";
    container = {
      HostConfig = {
        IpcMode = "host";
        CapAdd = [ "SYS_ADMIN" "SYS_NICE" "SYS_PTRACE" "NET_RAW" "MKNOD" "NET_ADMIN" ];
        SecurityOpt = [ "seccomp=unconfined" "apparmor=unconfined" ];
        Ulimits = [ { Name = "nofile"; Hard = 10240; Soft = 10240; } ];
        Privileged = false;
        DeviceCgroupRules = [ "c 13:* rmw" "c 244:* rmw" ];
      };
    };
  }
]