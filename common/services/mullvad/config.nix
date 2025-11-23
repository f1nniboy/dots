{
  relay_settings = {
    normal = {
      providers = "any";
      ownership = "any";
      tunnel_protocol = "wireguard";

      wireguard_constraints = {
        port = "any";
        ip_version.only = "v4";
        use_multihop = false;
      };

      openvpn_constraints.port = "any";
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
    udp2tcp.port = "any";
    shadowsocks.port = "any";
  };

  bridge_state = "auto";
  custom_lists.custom_lists = [ ];

  api_access_methods = {
    direct = {
      id = "25236afd-1e2a-45f3-92b0-99c909475e01";
      name = "Direct";
      enabled = true;
      access_method.built_in = "direct";
    };

    mullvad_bridges = {
      id = "bb0de8b7-92a8-429d-bcf1-3d1a1f637ac8";
      name = "Mullvad Bridges";
      enabled = true;
      access_method.built_in = "bridge";
    };

    encrypted_dns_proxy = {
      id = "51a56ed7-a059-4657-923e-41c152635859";
      name = "Encrypted DNS proxy";
      enabled = true;
      access_method.built_in = "encrypted_dns_proxy";
    };

    custom = [ ];
  };

  allow_lan = true;
  block_when_disconnected = true;
  auto_connect = false;

  tunnel_options = {
    openvpn.mssfix = null;

    wireguard = {
      mtu = null;
      quantum_resistant = "auto";
      daita = {
        enabled = false;
        use_multihop_if_necessary = true;
      };
      rotation_interval = null;
    };

    generic.enable_ipv6 = false;

    dns_options = {
      state = "custom";
      default_options = {
        block_ads = false;
        block_trackers = false;
        block_malware = false;
        block_adult_content = false;
        block_gambling = false;
        block_social_media = false;
      };
      custom_options.addresses = [ "100.100.100.100" ];
    };
  };

  relay_overrides = [ ];
  show_beta_releases = false;
  settings_version = 11;
}
