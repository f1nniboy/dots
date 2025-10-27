#!/usr/bin/env bash

set -euo pipefail

declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[1;33m'
declare -r CYAN='\033[0;36m'
declare -r BOLD='\033[1m'
declare -r NC='\033[0m'

log_info()    { echo -e "${CYAN}${BOLD}>>>${NC} $1"; }
log_success() { echo -e "${GREEN}${BOLD}>>>${NC} $1"; }
log_warn()    { echo -e "${YELLOW}${BOLD}>>>${NC} $1"; }
log_error()   { echo -e "${RED}${BOLD}>>>${NC} $1" >&2; exit 1; }

run_task() {
    local task_name="$1"
    shift
    log_info "${BOLD}starting${NC}: $task_name"
    "$@" && log_success "${BOLD}completed${NC}: $task_name" || log_error "${BOLD}failed${NC}: $task_name"
}

undo_changes() {
    umount -R /mnt 2>/dev/null || true
    cryptsetup close cryptroot 2>/dev/null || true
}

setup_disks() {
    local device_name="$1"
    just setup-disks "$device_name"
}

mount_filesystems() {
    mount -t tmpfs none /mnt
    mkdir -p /mnt/{boot,nix,etc/ssh,var/{lib,log}}
    mount /dev/disk/by-label/boot /mnt/boot
    mount /dev/disk/by-label/nix /mnt/nix
    mkdir -p /mnt/nix/{secret/initrd,persist/{etc/ssh,var/{lib,log}}}
    chmod 0700 /mnt/nix/secret
    mount -o bind /mnt/nix/persist/var/log /mnt/var/log
}

generate_ssh_key() {
    ssh-keygen -t ed25519 -N "" -C "" -f /mnt/nix/secret/initrd/ssh_host_ed25519_key
}

generate_age_key() {
    nix-shell --extra-experimental-features flakes -p ssh-to-age --run \
        'cat /mnt/nix/secret/initrd/ssh_host_ed25519_key.pub | ssh-to-age'
}

main() {
    [ $# -ne 1 ] && log_error "usage: $0 <device_name>"
    local device_name="$1"

    log_warn "this script will prepare the system for NixOS installation"
    read -n 1 -s -r -p "press any key to continue ..."
    echo

    run_task "undoing previous changes" undo_changes
    run_task "setting up disks" setup_disks "$device_name"
    run_task "mounting filesystems" mount_filesystems
    run_task "generating SSH host key" generate_ssh_key
    run_task "generating secrets key" generate_age_key

    echo -e "\n${BOLD}next steps:${NC}"
    echo -e "${BOLD}-${NC} add the machine's public host key to ${BOLD}.sops.yaml${NC}"
    echo -e "${BOLD}-${NC} install with: ${BOLD}sudo nixos-install --no-root-passwd --root /mnt --flake ${PWD}#${device_name}${NC}"
}

main "$@"
