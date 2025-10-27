{ cfg, ... }:
# TODO: don't hardcode username
#       - the config example in the README lies about
#         `null` being used to reference all users,
#         it doesn't work
''
  bind = "localhost:${toString cfg.port}"
  default_host = "0x0.st"
  upload_limit = 100
  strip_exif = true

  users {
    finn = "0x0.st"
  }

  host "0x0.st" {
    kind = "form"
    url = "https://0x0.st"
    file_field = "file"
  }
''
