{ cfg, vars, ... }:
''
  bind = "localhost:${toString cfg.port}"
  default_host = "0x0.st"
  upload_limit = 100
  strip_exif = true

  users {
    ${vars.user.nick} = "0x0.st"
  }

  host "0x0.st" {
    kind = "form"
    url = "https://0x0.st"
    file_field = "file"
  }
''
