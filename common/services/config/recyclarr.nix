{ config, ... }:
{
  radarr = {
    radarr = {
      api_key = {
        _secret = "/run/credentials/recyclarr.service/radarr_api-key";
      };
      base_url = "http://localhost:${toString config.services.radarr.settings.server.port}";

      media_naming = {
        folder = "default";
        movie = {
          rename = true;
          standard = "jellyfin-imdb";
        };
      };

      replace_existing_custom_formats = true;
      delete_old_custom_formats = true;

      quality_definition = {
        type = "movie";
      };

      quality_profiles = [
        {
          name = "UHD";
          min_format_score = 10000;
          score_set = "german";
          quality_sort = "top";

          upgrade = {
            allowed = false;
            until_quality = "Merged QPs";
            until_score = 35000;
          };

          reset_unmatched_scores = {
            enabled = true;
          };

          qualities = [
            {
              name = "Merged QPs";
              qualities = [
                "Bluray-2160p"
                "WEBDL-2160p"
                "WEBRip-2160p"
              ];
            }
          ];
        }

        {
          name = "HD";
          min_format_score = 10000;
          score_set = "german";
          quality_sort = "top";

          upgrade = {
            allowed = false;
            until_quality = "Merged QPs";
            until_score = 35000;
          };

          reset_unmatched_scores = {
            enabled = true;
          };

          qualities = [
            {
              name = "Merged QPs";
              qualities = [
                "Bluray-1080p"
                "WEBRip-1080p"
                "WEBDL-1080p"
              ];
            }
          ];
        }
      ];

      custom_formats = [
        {
          trash_ids = [
            # German Audio
            "86bc3115eb4e9873ac96904a4a68e19e" # German
            "6aad77771dabe9d3e9d7be86f310b867" # German DL (undefined)
            "f845be10da4f442654c13e1f2c3d6cd5" # German DL
            "4eadb75fb23d09dfc0a8e3f687e72287" # Not German or English

            # German HQ Release Groups
            "54795711b78ea87e56127928c423689b" # German Bluray Tier 01
            "1bfc773c53283d47c68e535811da30b7" # German Bluray Tier 02
            "aee01d40cd1bf4bcded81ee62f0f3659" # German Bluray Tier 03
            "a2ab25194f463f057a5559c03c84a3df" # German Web Tier 01
            "08d120d5a003ec4954b5b255c0691d79" # German Web Tier 02
            "439f9d71becaed589058ec949e037ff3" # German Web Tier 03
            "2d136d4e33082fe573d06b1f237c40dd" # German Scene

            # German Unwanted
            "263943bc5d99550c68aad0c4278ba1c7" # German LQ
            "03c430f326f10a27a9739b8bc83c30e4" # German Microsized
            "a826ee9e46607bc61795c85a6f2b1279" # German LQ (Release Title)

            # Misc
            "e7718d7a3ce595f289bfee26adc178f5" # Repack/Proper
            "ae43b294509409a6a13919dedd4764c4" # Repack2
            "5caaaa1c08c1742aa4342d8c4cc463f2" # Repack3

            # Unwanted
            "ed38b889b31be83fda192888e2286d83" # BR-DISK
            "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
            "90a6f9a284dff5103f6346090e6280c8" # LQ
            "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
            "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
            "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
            "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
            "0a3f082873eb454bde444150b70253cc" # Extras
            "cae4ca30163749b891686f95532519bd" # AV1
            "c465ccc73923871b3eb1802042331306" # Line/Mic Dubbed

            # Streaming Services
            "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE
            "16622a6911d1ab5d5b8b713d5b0036d4" # CRiT
            "2a6039655313bf5dab1e43523b62c374" # MA
            "b3b3a6ac74ecbd56bcdbefa4799fb9df" # AMZN
            "40e9380490e748672c2522eaaeb692f7" # ATVP
            "84272245b2988854bfb76a16e60baea5" # DSNP
            "509e5f41146e278f9eab1ddaceb34515" # HBO
            "5763d1b0ce84aff3b21038eea8e9b8ad" # HMAX
            "526d445d4c16214309f0fd2b3be18a89" # Hulu
            "e0ec9672be6cac914ffad34a6b077209" # iT
            "6a061313d22e51e0f25b7cd4dc065233" # MAX
            "170b1d363bd8516fbf3a3eb05d4faff6" # NF
            "c9fd353f8f5f1baf56dc601c4cb29920" # PCOK
            "e36a0ba1bc902b26ee40818a1d59b8bd" # PMTP
            "c2863d2a50c9acad1fb50e53ece60817" # STAN
          ];
          assign_scores_to = [
            { name = "UHD"; }
            { name = "HD"; }
          ];
        }

        {
          trash_ids = [
            # HQ Release Groups
            "ed27ebfef2f323e964fb1f61391bcb35" # HD Bluray Tier 01
            "c20c8647f2746a1f4c4262b0fbbeeeae" # HD Bluray Tier 02
            "5608c71bcebba0a5e666223bae8c9227" # HD Bluray Tier 03
            "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
            "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
            "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03

            # Resolution
            "3bc8df3a71baaac60a31ef696ea72d36" # German 1080p Booster
            "b2be17d608fc88818940cd1833b0b24c" # 720p
            "820b09bb9acbfde9c35c71e0e565dad8" # 1080p
          ];
          assign_scores_to = [
            {
              name = "HD";
            }
          ];
        }

        {
          trash_ids = [
            # HQ Release Groups
            "4d74ac4c4db0b64bff6ce0cffef99bf0" # UHD Bluray Tier 01
            "a58f517a70193f8e578056642178419d" # UHD Bluray Tier 02
            "e71939fae578037e7aed3ee219bbe7c1" # UHD Bluray Tier 03
            "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
            "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
            "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03

            # Resolution
            "3bc8df3a71baaac60a31ef696ea72d36" # German 1080p Booster
            "cc7b1e64e2513a6a271090cdfafaeb55" # German 2160p Booster
            "b2be17d608fc88818940cd1833b0b24c" # 720p
            "820b09bb9acbfde9c35c71e0e565dad8" # 1080p
            "fb392fb0d61a010ae38e49ceaa24a1ef" # 2160p
          ];
          assign_scores_to = [
            {
              name = "UHD";
            }
          ];
        }
      ];
    };
  };
  sonarr = {
    sonarr = {
      api_key = {
        _secret = "/run/credentials/recyclarr.service/sonarr_api-key";
      };
      base_url = "http://localhost:${toString config.services.sonarr.settings.server.port}";

      media_naming = {
        series = "jellyfin";
        season = "default";
        episodes = {
          rename = true;
          standard = "default";
          daily = "default";
          anime = "default";
        };
      };

      replace_existing_custom_formats = true;
      delete_old_custom_formats = true;

      quality_definition = {
        type = "series";
      };

      quality_profiles = [
        {
          name = "UHD";
          min_format_score = 10000;
          score_set = "german";
          quality_sort = "top";

          upgrade = {
            allowed = false;
            until_quality = "Merged QPs";
            until_score = 35000;
          };

          reset_unmatched_scores = {
            enabled = true;
          };

          qualities = [
            {
              name = "Merged QPs";
              qualities = [
                "Bluray-2160p"
                "WEBDL-2160p"
                "WEBRip-2160p"
              ];
            }
          ];
        }

        {
          name = "HD";
          min_format_score = 10000;
          score_set = "german";
          quality_sort = "top";

          upgrade = {
            allowed = false;
            until_quality = "Merged QPs";
            until_score = 35000;
          };

          reset_unmatched_scores = {
            enabled = true;
          };

          qualities = [
            {
              name = "Merged QPs";
              qualities = [
                "Bluray-1080p"
                "WEBDL-1080p"
                "WEBRip-1080p"
              ];
            }
          ];
        }
      ];

      custom_formats = [
        {
          trash_ids = [
            "8a9fcdbb445f2add0505926df3bb7b8a" # German
            "ed51973a811f51985f14e2f6f290e47a" # German DL
            "c5dd0fd675f85487ad5bdf97159180bd" # German DL (undefined)
            "133589380b89f8f8394320901529bac1" # Not German or English

            # German HQ Release Groups
            "7940b2fb0278f27cf4f70187f2be95d6" # German Bluray Tier 01
            "83b336a90d90d6b35ca673b007f80661" # German Bluray Tier 02
            "d8f8e1539827967e0e564833e6c08d33" # German Bluray Tier 03
            "68be37323132b35cf333c81a2ac8fc16" # German Web Tier 01
            "f51b96a50b0e6196cb69724b7833d837" # German Web Tier 02
            "bda67c2c0aae257308a4723d92475b86" # German Web Tier 03
            "c2eec878fa1989599c226ce4c287d6a7" # German Scene

            # German Unwanted
            "a6a6c33d057406aaad978a6902823c35" # German LQ
            "237eda4ef550a97da2c9d87b437e500b" # German Microsized
            "d80c9f7cd2aad50271f1bd4e53125778" # German LQ (Release Title)

            # Misc
            "ec8fa7296b64e8cd390a1600981f3923" # Repack/Proper
            "eb3d5cc0a2be0db205fb823640db6a3c" # Repack2
            "44e7c4de10ae50265753082e5dc76047" # Repack3

            # Unwanted
            "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
            "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
            "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
            "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
            "23297a736ca77c0fc8e70f8edd7ee56c" # Upscaled
            "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
            "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1

            # Streaming Services
            "d660701077794679fd59e8bdf4ce3a29" # AMZN
            "f67c9ca88f463a48346062e8ad07713f" # ATVP
            "77a7b25585c18af08f60b1547bb9b4fb" # CC
            "36b72f59f4ea20aad9316f475f2d9fbb" # DCU
            "dc5f2bb0e0262155b5fedd0f6c5d2b55" # DSCP
            "89358767a60cc28783cdc3d0be9388a4" # DSNP
            "7a235133c87f7da4c8cccceca7e3c7a6" # HBO
            "a880d6abc21e7c16884f3ae393f84179" # HMAX
            "f6cce30f1733d5c8194222a7507909bb" # Hulu
            "0ac24a2a68a9700bcb7eeca8e5cd644c" # iT
            "81d1fbf600e2540cee87f3a23f9d3c1c" # MAX
            "d34870697c9db575f17700212167be23" # NF
            "1656adc6d7bb2c8cca6acfb6592db421" # PCOK
            "c67a75ae4a1715f2bb4d492755ba4195" # PMTP
            "ae58039e1319178e6be73caab5c42166" # SHO
            "1efe8da11bfd74fbbcd4d8117ddb9213" # STAN
            "9623c5c9cac8e939c1b9aedd32f640bf" # SYFY
          ];
          assign_scores_to = [
            { name = "UHD"; }
            { name = "HD"; }
          ];
        }

        {
          trash_ids = [
            # HQ Release Groups
            "d6819cba26b1a6508138d25fb5e32293" # HD Bluray Tier 01
            "c2216b7b8aa545dc1ce8388c618f8d57" # HD Bluray Tier 02
            "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
            "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
            "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03

            # Resolution
            "9aa0ca0d2d66b6f6ee51fc630f46cf6f" # German 1080p Booster
            "c99279ee27a154c2f20d1d505cc99e25" # 720p
            "290078c8b266272a5cc8e251b5e2eb0b" # 1080p
          ];
          assign_scores_to = [
            {
              name = "HD";
            }
          ];
        }

        {
          trash_ids = [
            # HQ Source Groups
            "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
            "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
            "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
            "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene

            # Resolution
            "9aa0ca0d2d66b6f6ee51fc630f46cf6f" # German 1080p Booster
            "b493cd40d8a3bbf2839127a706bdb673" # German 2160p Booster
            "c99279ee27a154c2f20d1d505cc99e25" # 720p
            "290078c8b266272a5cc8e251b5e2eb0b" # 1080p
            "1bef6c151fa35093015b0bfef18279e5" # 2160p
          ];
          assign_scores_to = [
            {
              name = "UHD";
            }
          ];
        }
      ];
    };
  };
}
