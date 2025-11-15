# Adding a new machine

# 1. Clone this repo
- Clone this repo to the new host
- Generate a random name using `random-name.sh`
  ```console
  $ sudo ./scripts/random-name.sh
  ```

## 2. Create new device
- Add new configuration for the device in `machines/...`
  - Update `flake.nix` to include device in `nixosConfigurations`
  - Create proper disk configuration at `disk.nix` (using `disko`)

## 3. Run preparation script
- Execute the preparation script with chosen device name:
  ```console
  $ ./scripts/install.sh <device_name>
  ```

## 4. Copy SOPS public key
- Copy generated SOPS public key for the host to `.sops.yaml`
  - on a host that already has NixOS installed
- Run `just sops-update`
- Push to repo & pull new changes on new host

## 5. Generate hardware config
- Generate hardware config using `nixos-generate-config --dir <...>`
- Copy generated config to `machines/.../hardware.nix`

## 6. Push everything to repo
- Push all changes made above to repo

## 7. Install
- Build closure using `colmena`
  ```console
  $ colmena build --on node --no-build-on-target
  ```

- Copy the closure to new host
  ```console
  $ nix copy PATH --to ssh://me@HOST
  ```

- Install built closure on the new host
  ```console
  $ sudo nixos-install --root /mnt --no-root-passwd --system PATH
  ```

**Done!**
