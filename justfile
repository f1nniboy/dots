default:
	just --list

deploy machine ip='':
	#!/usr/bin/env sh
	name="$(nix eval --raw --file ./vars.nix user.name)"
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

build-iso:
	nix build .#nixosConfigurations.iso.config.system.build.isoImage

sops-edit:
	sops secrets/secrets.yaml

sops-rotate:
	for file in secrets/*; do sops --rotate --in-place "$file"; done
	
sops-update:
	for file in secrets/*; do sops updatekeys "$file"; done
