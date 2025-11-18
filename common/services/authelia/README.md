# Creating a new client
## ID
```console
$ nix run nixpkgs#authelia -- crypto rand --length 72 --charset rfc3986
```

## Secret
```console
$ nix run nixpkgs#authelia -- crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986
```
