## adding a new machine
### 1. create new device
- add new configuration for the device in `machines/...`
  - update `flake.nix` to include device in `nixosConfigurations`
  - create proper disk configuration at `disk.nix` (using `disko`)

### 2. run preparation script
- execute the preparation script with your chosen device name:
```
./scripts/install.sh <device_name>
```

### 3. copy sops public key
- copy generated sops public key for the device to `.sops.yaml`
- run `just sops-update`

### 4. generate hardware config
- generate hardware config using `nixos-generate-config --dir <...>`
- copy generated config to `machines/.../hardware.nix`

### 5. push everything to repo
- push all changes made above to repo

### 6. install
```
sudo nixos-install --no-root-passwd --root /mnt --flake /home/nixos/dots#<device_name>
```