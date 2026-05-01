#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}NixOS Desktop Installation Script${NC}"
echo "=================================="
echo ""

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${YELLOW}Usage: $0 <target-ip> [disk-device]${NC}"
    echo ""
    echo "Example:"
    echo "  $0 192.168.1.100"
    echo "  $0 192.168.1.100 /dev/nvme0n1"
    echo ""
    echo "Note: Default disk is /dev/nvme0n1"
    exit 1
fi

TARGET_IP="$1"
DISK="${2:-/dev/nvme0n1}"
HOST="desktop"
SSH_KEY="$HOME/.ssh/nixos-install"

echo -e "Target IP: ${YELLOW}$TARGET_IP${NC}"
echo -e "Disk:      ${YELLOW}$DISK${NC}"
echo -e "Host:      ${YELLOW}$HOST${NC}"
echo ""

# Check for nixos-anywhere
if ! command -v nixos-anywhere &> /dev/null; then
    echo -e "${YELLOW}nixos-anywhere not found. Installing...${NC}"
    nix shell nixpkgs#nixos-anywhere -c echo "nixos-anywhere ready"
fi

# Generate SSH key if it doesn't exist
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${YELLOW}Generating SSH key for installation...${NC}"
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "nixos-install"
    echo -e "${GREEN}SSH key generated: $SSH_KEY${NC}"
    echo ""
    echo -e "${YELLOW}Add this public key to your target's authorized_keys:${NC}"
    cat "${SSH_KEY}.pub"
    echo ""
    echo "On the target machine, run:"
    echo "  mkdir -p ~/.ssh && echo '$(cat ${SSH_KEY}.pub)' >> ~/.ssh/authorized_keys"
    echo ""
    read -p "Press Enter when ready..."
fi

# Test SSH connection
echo -e "${YELLOW}Testing SSH connection...${NC}"
if ! ssh -i "$SSH_KEY" -o ConnectTimeout=5 "root@$TARGET_IP" "echo 'SSH OK'" 2>/dev/null; then
    echo -e "${RED}Failed to connect via SSH${NC}"
    echo ""
    echo "Ensure:"
    echo "  1. Target machine is booted from NixOS ISO"
    echo "  2. SSH is running (systemctl start sshd)"
    echo "  3. Root password is set (passwd)"
    echo "  4. The SSH key has been added to authorized_keys"
    exit 1
fi

echo -e "${GREEN}SSH connection successful!${NC}"
echo ""

# Confirm disk
echo -e "${YELLOW}WARNING: This will ERASE all data on $DISK${NC}"
read -p "Are you sure you want to continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Installation cancelled."
    exit 0
fi

# Update disk config if needed
if [ "$DISK" != "/dev/nvme0n1" ]; then
    echo -e "${YELLOW}Updating disk configuration to use $DISK...${NC}"
    sed -i "s|/dev/nvme0n1|$DISK|g" "hosts/${HOST}/disk.nix"
fi

# Run nixos-anywhere
echo -e "${YELLOW}Starting NixOS installation...${NC}"
echo "This may take 10-30 minutes depending on your connection."
echo ""

nixos-anywhere \
    --flake ".#${HOST}" \
    --generate-hardware-config nixos-generate-config "hosts/${HOST}/hardware.nix" \
    -i "$SSH_KEY" \
    "root@${TARGET_IP}"

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Reboot the target machine"
echo "  2. Login as 'billy' (no password for sudo)"
echo "  3. Clone this repo and run: home-manager switch --flake .#billy"
echo ""
echo -e "${YELLOW}To reboot now, run:${NC}"
echo "  ssh -i $SSH_KEY root@$TARGET_IP reboot"
