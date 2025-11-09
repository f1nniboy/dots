default:
    just --list

deploy-remote on='':
    #!/usr/bin/env sh
    if [ -z "{{ on }}" ]; then
        nix run github:zhaofengli/colmena -- apply
    else
        nix run github:zhaofengli/colmena -- apply --on="{{ on }}"
    fi

deploy-local:
    # TODO: run rootless
    sudo nix run github:zhaofengli/colmena -- apply-local --verbose

up input='':
    nix flake update "{{ input }}"

lint:
    statix check .

gc:
    sudo nix-collect-garbage -d && nix-collect-garbage -d

repair:
    sudo nix-store --verify --check-contents --repair

setup-disks machine:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./machines/{{ machine }}/disk.nix

build-iso:
    nix build .#nixosConfigurations.iso.config.system.build.isoImage

sops-edit path:
    sops "secrets/{{ path }}.yaml"

sops-rotate:
    for file in secrets/* secrets/hosts/*; do sops --rotate --in-place "$file"; done

sops-update:
    for file in secrets/* secrets/hosts/*; do sops updatekeys "$file"; done
