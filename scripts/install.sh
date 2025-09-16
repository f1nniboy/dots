#!/usr/bin/env bash

set -euo pipefail

# Colors for logging
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[1;33m'
declare -r CYAN='\033[0;36m'
declare -r BOLD='\033[1m'
declare -r NC='\033[0m'

# Logging functions
log_info() { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1" >&2; exit 1; }

# Task execution wrapper
run_task() {
    local task_name="$1"
    shift
    log_info "Starting: $task_name"
    "$@" && log_success "Completed: $task_name" || log_error "Failed: $task_name"
}

# Linux tasks
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

# Main function
main() {
    [ $# -ne 1 ] && log_error "Usage: $0 <device_name> (e.g., desktop, laptop)"
    local device_name="$1"

    [ "$(uname)" != "Linux" ] && log_error "Only Linux is supported"

    log_warn "This script will prepare the system for NixOS installation using disko. It is irreversible."
    read -n 1 -s -r -p "Press any key to continue or Ctrl+C to abort..."
    echo

    run_task "Undoing previous changes" undo_changes
    run_task "Setting up disks with disko" setup_disks "$device_name"
    run_task "Mounting filesystems" mount_filesystems
    run_task "Generating SSH host key" generate_ssh_key
    run_task "Generating age key for sops-nix" generate_age_key

    log_success "NixOS preparation completed."
    echo -e "\n${BOLD}Next steps:${NC}"
    echo -e "${BOLD}- Commit and push the new server's public host key to sops-nix${NC}"
    echo -e "${BOLD}- Install NixOS with:${NC}"
    echo -e "${BOLD}sudo nixos-install --no-root-passwd --root /mnt --flake github:eh8/chenglab#$device_name${NC}"
}

main "$@"