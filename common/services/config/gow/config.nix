{ config, pkgs, ... }:
let
  apps = import ./apps.nix;
  clients = import ./clients.nix;
  gstreamer = import ./gstreamer.nix;

  generateApp = service:
  ''
    [[apps]]
    icon_png_path = "${service.icon}"
    start_virtual_compositor = true
    title = "${service.title}"

    [apps.runner]
    base_create_json = ''''
      ${builtins.toJSON service.container}
    ''''
    devices = []
    env = ${builtins.toJSON service.env}
    image = '${service.image}'
    mounts = []
    name = '${service.title}'
    ports = []
    type = 'docker'
  '';

  generateClient = client:
  ''
    [[paired_clients]]
    app_state_folder = "${client.id}"
    client_cert = ''''${client.cert}''''
  '';

  tomlServices = builtins.map generateApp apps;
  tomlClients = builtins.map generateClient clients;
in
''
config_version = 5
hostname = 'Wolf'
uuid = '${config.custom.services.gow.id}'

${builtins.concatStringsSep "\n" tomlServices}

${builtins.concatStringsSep "\n" tomlClients}

${gstreamer}
''
