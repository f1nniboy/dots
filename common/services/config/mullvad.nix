builtins.toJSON {
  settings_version = 11;
  show_beta_releases = false;

  relay_settings = {
    normal = {
      providers = "any";
      ownership = "any";
      tunnel_protocol = "wireguard";
      wireguard_constraints = {
        port = "any";
        ip_version = "any";
        use_multihop = true;
      };
      openvpn_constraints = {
        port = "any";
      };
    };
  };
  bridge_settings = {
    bridge_type = "normal";
    normal = {
      location = "any";
      providers = "any";
      ownership = "any";
    };
    custom = null;
  };
  obfuscation_settings = {
    selected_obfuscation = "auto";
    udp2tcp = {
      port = "any";
    };
    shadowsocks = {
      port = "any";
    };
  };
  bridge_state = "auto";
  custom_lists = {
    custom_lists = [];
  };
  api_access_methods = {
    direct = {
      id = "cc223e38-a720-4835-8762-6d2a753b1a54";
      name = "Direct";
      enabled = true;
      access_method = {
        built_in = "direct";
      };
    };
    mullvad_bridges = {
      id = "c972ce5c-3b9d-4db0-a7da-3839912d1978";
      name = "Mullvad Bridges";
      enabled = true;
      access_method = {
        built_in = "bridge";
      };
    };
    encrypted_dns_proxy = {
      id = "ed1b020a-547f-4399-9c9e-605eac251883";
      name = "Encrypted DNS proxy";
      enabled = true;
      access_method = {
        built_in = "encrypted_dns_proxy";
      };
    };
    custom = [];
  };
  allow_lan = true;
  block_when_disconnected = false;
  auto_connect = false;
  tunnel_options = {
    openvpn = {
      mssfix = null;
    };
    wireguard = {
      mtu = null;
      quantum_resistant = "auto";
      daita = {
        enabled = true;
        use_multihop_if_necessary = true;
      };
      rotation_interval = null;
    };
    generic = {
      enable_ipv6 = false;
    };
    dns_options = {
      state = "default";
      default_options = {
        block_ads = false;
        block_trackers = false;
        block_malware = false;
        block_adult_content = false;
        block_gambling = false;
        block_social_media = false;
      };
      custom_options = {
        addresses = [];
      };
    };
  };
  relay_overrides = [];
}