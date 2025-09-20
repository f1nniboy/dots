[
  {
    title = "Steam";
    icon = "https://games-on-whales.github.io/wildlife/apps/steam/assets/icon.png";
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
    env = [
      "PROTON_LOG=1"
      "RUN_SWAY=true"
      "GOW_REQUIRED_DEVICES=/dev/input/* /dev/dri/* /dev/nvidia*"
    ];
  }
]