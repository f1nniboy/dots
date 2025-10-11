default:
	just --list

deploy machine ip='':
	#!/usr/bin/env sh
	if [ -z "{{ip}}" ]; then
		sudo nixos-rebuild switch --no-reexec --show-trace --flake ".#{{machine}}"
	else
		nixos-rebuild switch --no-reexec --flake ".#{{machine}}" \
			--target-host "me@{{ip}}" --build-host "me@{{ip}}" \
			--sudo --show-trace
	fi

up:
	nix flake update

lint:
	statix check .

gc:
	sudo nix-collect-garbage -d && nix-collect-garbage -d

repair:
	sudo nix-store --verify --check-contents --repair

setup-disks machine:
	sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./machines/{{machine}}/disk.nix

build-iso:
	nix build .#nixosConfigurations.iso.config.system.build.isoImage

sops-edit:
	sops secrets/secrets.yaml

sops-rotate:
	for file in secrets/*; do sops --rotate --in-place "$file"; done

sops-update:
	for file in secrets/*; do sops updatekeys "$file"; done
