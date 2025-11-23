{
  inputs,
  system,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.services.blog;
in
{
  options.custom.services.blog = {
    enable = custom.enableOption;
  };

  config = mkIf cfg.enable {
    custom = {
      services = {
        caddy.hosts = {
          blog = {
            type = "root";
            target = toString inputs.blog.packages.${system}.default;
            ca = "public";
            extra = ''
              # cache static assets
              @static {
                path *.css *.webp *.ico *.svg *.woff2
              }
              header @static Cache-Control "public, max-age=31536000, immutable"

              # use custom error pages
              handle_errors {
               	rewrite * /{err.status_code}.html
               	file_server
              }

              # compression
              encode zstd gzip
            '';
          };
        };
      };
    };
  };
}
