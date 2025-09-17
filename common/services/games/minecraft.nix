{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.services.minecraft;
  ports = {
    java = 25565;
    bedrock = 19132;
  };
in
{
  options.custom.services.minecraft = {
    enable = mkEnableOption "Minecraft server";
  };

  config = mkIf cfg.enable {
    services.minecraft-servers = {
      enable = true;
      dataDir = "/var/lib/minecraft";
      eula = true;

      servers = {
        sff = {
          enable = true;
          autoStart = true;
          package = pkgs.quiltServers.quilt-1_21_8;

          managementSystem = {
            systemd-socket.enable = true;
            tmux.enable = false;
          };

          serverProperties = {
            max-players = 10;
            motd = "ok";

            level-seed = "4353181439174722661";
            spawn-protection = 0;
            enable-lan-visibility = false;

            # cracked stuff
            enforce-secure-profile = false;
            online-mode = true;
          };

          operators = {
            f1nniboy = {
              uuid = "52e75143-a651-4755-b216-0497683f53bc";
              level = 4;
              bypassesPlayerLimit = true;
            };
          };

          files = {
            mods = with pkgs; pkgs.linkFarmFromDrvs "mods" (
              builtins.attrValues {
                FabricAPI = fetchurl { url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/ax9iQEs0/fabric-api-0.131.0%2B1.21.8.jar"; sha512 = "a4c7030d16eb012745b1ff3cb5487b08b88500259f5269a87815868ee686c02d5ba93cf2645de0f023f74c7cd78415c5be8938ce3d8fff24ccb1219ebb7a3a2b"; };
                Lithium = fetchurl { url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/pDfTqezk/lithium-fabric-0.18.0%2Bmc1.21.8.jar"; sha512 = "6c69950760f48ef88f0c5871e61029b59af03ab5ed9b002b6a470d7adfdf26f0b875dcd360b664e897291002530981c20e0b2890fb889f29ecdaa007f885100f"; };
                NoChatReports = fetchurl { url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/LhwpK0O6/NoChatReports-FABRIC-1.21.7-v2.14.0.jar"; sha512 = "6e93c822e606ad12cb650801be1b3f39fcd2fef64a9bb905f357eb01a28451afddb3a6cadb39c112463519df0a07b9ff374d39223e9bf189aee7e7182077a7ae"; };
                Debugify = fetchurl { url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/WLSwJeXa/debugify-1.21.8%2B1.0.jar"; sha512 = "5cbb7551e83abcc712a2d4b544d7f19cc1855eaede2350588b3f909966ae9248a7cdfd0c4d3cf53b796477f4327d735dadf83eddf40403a338d96ea9b9d727ca"; };
                CCME = fetchurl { url = "https://cdn.modrinth.com/data/VSNURh3q/versions/tlZRTK1v/c2me-fabric-mc1.21.8-0.3.4.0.0.jar"; sha512 = "30cbc520cb8349036d55a1cb1f26964cf02410cf6d6a561d9cc07164d7566a3a7564367de62510f2bab50723c2c7c401718001153fa833560634ce4b2e212767"; };
                LetMeDespawn = fetchurl { url = "https://cdn.modrinth.com/data/vE2FN5qn/versions/M9egl08c/letmedespawn-1.21.5-fabric-1.5.1.jar"; sha512 = "28b6360d1feb0908a1acfaac8309896f0072dc8e4a789cd4e36e52535bb452f054408d2474e737fad740532e34bc08f31ea5924d3ad75d9c51c1dc0c2258bff6"; };
                FallingTree = fetchurl { url = "https://cdn.modrinth.com/data/Fb4jn8m6/versions/vs4XSgGN/FallingTree-1.21.8-1.21.8.2.jar"; sha512 = "c3a12bc095fdd603b6bcd972772a937a0d6ce8b3bece81d1b4bc2cb45de7d6d5d4fabbe056f26ebe04f8052a92e3c62618b7b97767bd673abccb3f310e3ac457"; };
                DoubleDoors = fetchurl { url = "https://cdn.modrinth.com/data/JrvR9OHr/versions/Kaxph4k0/doubledoors-1.21.8-7.1.jar"; sha512 = "09370159d41925eec07558e65cf06cff99253503d55ff13b206bae1f2914c4e8cdab938747526e3e75f900793fa95eaf2636e7eead1f4bdfc9b0d9efeacfc50e"; };
                UniversalGraves = fetchurl { url = "https://cdn.modrinth.com/data/yn9u3ypm/versions/gdZmLCZD/graves-3.8.1%2B1.21.6.jar"; sha512 = "8e97e86124445e1e04852c7567dca684ee2180f0a44b0884a3409c47da996b4fdc47c5ee1acefaf52666f11a8065bd92957615353641667a331f7378362a5746"; };
                Collective = fetchurl { url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/mld0ZPD9/collective-1.21.8-8.4.jar"; sha512 = "ef5fc74d45e6528fd3a358bff1ad038ace3cda1a3cd20ac91fe8a5215c39ca51f6d1e2c63f04df4bdb5c44d7798233cf6e71c03737badf677357f0a8f2bddcc9"; };
                Almanac = fetchurl { url = "https://cdn.modrinth.com/data/Gi02250Z/versions/mzFZuKaS/Almanac-1.21.5-fabric-1.4.5.jar"; sha512 = "ec831925f65bf3a398d0579cc6cae275effcfb61142a62ec3eff3d9cf58b91eb7cab953d34824c75e27074f09ce73d24b585897ac4253ab4e85af3105c780ed1"; };
                EasyAuth = fetchurl { url = "https://cdn.modrinth.com/data/aZj58GfX/versions/MsfOax3L/easyauth-mc1.21.6-3.3.5.jar"; sha512 = "11c0b856bf4031f3c3b03ae665960adfd0d6880b3d10e0f2a9e94413188c13a992383e79346211dcc4b26c5c10ac101fe342c5b885560d3f3e38cb21d2f05859"; };
                LuckPerms = fetchurl { url = "https://cdn.modrinth.com/data/Vebnzrzj/versions/uStOaYyZ/LuckPerms-Fabric-5.5.10.jar"; sha512 = "8985ee7fd0e1033022292e05cb7ad503ae82908bfacb92c269eb4e3895947a512c4e769e7110785ca55f14d4af04124c762515dbd2508bcd08fc7a107cbcc023"; };
                Tectonic = fetchurl { url = "https://cdn.modrinth.com/data/lWDHr9jE/versions/QmDm3jen/tectonic-3.0.8-fabric-1.21.8.jar"; sha512 = "04a80bf11b50a799a229a7c4eba3c99f741cb0a96780ac8e8d753ab106d9a21ab4c66cb42950b54d33b0d09b0c32d05f2410fddb7cd96b21d62545c2cd6322c8"; };
                Lithostitched = fetchurl { url = "https://cdn.modrinth.com/data/XaDC71GB/versions/ROo8a9VV/lithostitched-fabric-1.21.6-1.4.11.jar"; sha512 = "1d63192dba2dcc16f15652f3128a390da582fb5be09a4aa1ad3805c805da0fff3b15fbcade1ebbe9d503eaec1bda4a3e063902aba3d6eeca0eb8bce6fcddb859"; };
                Chunky = fetchurl { url = "https://cdn.modrinth.com/data/fALzjamp/versions/inWDi2cf/Chunky-Fabric-1.4.40.jar"; sha512 = "9e0386d032641a124fd953a688a48066df7f4ec1186f7f0f8b0a56d49dced220e2d6938ed56e9d8ead78bb80ddb941bc7873f583add8e565bdacdf62e13adc28"; };
                Geyser = fetchurl { url = "https://cdn.modrinth.com/data/wKkoqHrH/versions/QJQTyeNq/geyser-fabric-Geyser-Fabric-2.8.3-b911.jar"; sha512 = "9ba70266cc8e5100b7210e491c4843bdb39dc418995475bd338c0be18ca7abb509dee982e5274af5e682b39228ff1fcf7947de558e689f03d99257223b0eb6a2"; };
                DiscordMCChat = fetchurl { url = "https://cdn.modrinth.com/data/D0sHdnXY/versions/PtVawIb0/Discord-MC-Chat-2.5.0.jar"; sha512 = "5d653d21048cea1eeaff13bf1f63619133384385b4da21c5105c64e4b1b6ac67c04fd8534768d0a5125a9c940a4dc38ce64cba6b202e86e705a5ef9b45a8c4d5"; };
                FabricTailor = fetchurl { url = "https://cdn.modrinth.com/data/g8w1NapE/versions/86wiUAsQ/fabrictailor-2.8.0.jar"; sha512 = "9d203560cba5be4986780d3cc90515cfd31743a62929825afa5c286cddba423dd8fb4a6847b15238c373d753479a83600de4b73638806e0c0e13c27afcac99c2"; };
              }
            );

            "config/fallingtree.json" = {
              value = {
                trees = {
                  breakMode = "SHIFT_DOWN";
                };
              };
            };
          };
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ ports.java ];
      allowedUDPPorts = [ ports.java ports.bedrock ];
    };

    environment.persistence."/nix/persist" = {
      directories = [
        {
          directory = "/var/lib/minecraft";
          user = "minecraft";
          group = "minecraft";
          mode = "0700";
        }
      ];
    };

    custom.services.restic.paths = [
      "/var/lib/minecraft"
    ];
  };
}
