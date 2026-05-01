# Personal NixOS Infrastructure

NixOS configuration for personal desktop and future laptop.

## Structure

```
.
├── flake.nix              # Entry point with host definitions
├── home/
│   └── billy.nix         # Home Manager configuration
├── hosts/
│   └── desktop/          # Gaming desktop configuration
│       ├── configuration.nix
│       ├── hardware.nix
│       └── disk.nix
├── modules/
│   ├── system.nix        # Base system settings
│   ├── desktop.nix       # Hyprland, Pipewire, Bluetooth
│   └── gaming.nix        # Steam, Gamemode, AMD optimizations
└── scripts/
    └── install.sh        # nixos-anywhere helper
```

## Quick Start

### 1. Install NixOS (nixos-anywhere)

From any Linux machine with Nix:

```bash
# Install nixos-anywhere
nix shell nixpkgs#nixos-anywhere

# Generate SSH key for install
ssh-keygen -t ed25519 -f ~/.ssh/nixos-install -N ""

# Copy SSH key to target (must have SSH access)
ssh-copy-id -i ~/.ssh/nixos-install.pub root@<target-ip>

# Install NixOS
nixos-anywhere --flake .#desktop --generate-hardware-config nixos-generate-config root@<target-ip>
```

### 2. Post-Install: Activate Home Manager

On the installed system:

```bash
# Clone this repo
git clone <repo-url> ~/infrastructure
cd ~/infrastructure

# Apply home configuration
home-manager switch --flake .#billy
```

### 3. Development Workflow

```bash
# Update system
sudo nixos-rebuild switch --flake .#desktop

# Update home
home-manager switch --flake .#billy

# Update flake inputs
nix flake update

# Check flake
nix flake check
```

## Hardware

- **GPU**: AMD RX 7800 XT (Mesa RADV)
- **CPU**: AMD (microcode updates enabled)
- **Storage**: Single NVMe (`/dev/nvme0n1`)
- **Desktop**: Hyprland with Catppuccin theming

## Features

- **Gaming**: Steam, Proton, Gamemode, MangoHud
- **Desktop**: Hyprland, Waybar, Wofi, SDDM
- **Audio**: Pipewire with WirePlumber
- **Apps**: Discord, Firefox, Kitty terminal
- **Theme**: Catppuccin Mocha throughout

## Keybindings (Hyprland)

| Key | Action |
|-----|--------|
| `Super + Enter` | Open terminal (Kitty) |
| `Super + Q` | Close window |
| `Super + R` | App launcher (Wofi) |
| `Super + B` | Firefox |
| `Super + D` | Discord |
| `Super + L` | Lock screen |
| `Super + [1-0]` | Switch workspace |
| `Super + Shift + [1-0]` | Move window to workspace |
| `Print` | Screenshot (selection) |
| `Shift + Print` | Screenshot (full) |

## Adding a Second PC

1. Create `hosts/laptop/` directory
2. Copy and modify configuration files
3. Add to `flake.nix`:
   ```nix
   laptop = nixpkgs.lib.nixosSystem {
     inherit system;
     modules = [
       disko.nixosModules.disko
       ./hosts/laptop/configuration.nix
     ];
   };
   ```

## Troubleshooting

### Steam won't launch
```bash
steam --reset
```

### AMD GPU not detected
Check `lspci | grep VGA` and verify drivers in `hardware.nix`.

### Audio issues
```bash
systemctl --user restart pipewire pipewire-pulse
```
