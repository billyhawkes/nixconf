# Personal NixOS Infrastructure

NixOS configuration for personal desktop.

## Structure

```
.
├── flake.nix              # Entry point with host definitions
├── home/
│   └── billy.nix          # Home Manager configuration
├── hosts/
│   └── desktop/
│       ├── configuration.nix
│       └── hardware.nix
├── modules/
│   ├── system.nix         # Base system settings
│   ├── desktop.nix        # Hyprland, Pipewire, Bluetooth
│   └── gaming.nix         # Steam, Gamemode, AMD optimizations
└── scripts/
    └── install.sh         # nixos-anywhere helper (deprecated for GUI installs)
```

## Initial Install (GUI)

1. Install NixOS via the graphical installer on the target machine
2. Enable SSH: `sudo systemctl enable --now sshd`
3. Generate hardware config from the target:
   ```bash
   ssh billy@<ip> "sudo nixos-generate-config --show-hardware-config" > hosts/desktop/hardware.nix
   ```

## Remote Rebuild (from this Mac)

```bash
nix shell nixpkgs/nixos-unstable#nixos-rebuild -c \
    nixos-rebuild --no-reexec switch \
    --flake ".#desktop" \
    --build-host "billy@<ip>" \
    --target-host "billy@<ip>" \
    --sudo
```

## Home Manager (on the target machine)

```bash
home-manager switch --flake .#billy
```

## Useful Commands

```bash
nix flake update          # Update flake inputs
nix flake check            # Check flake
```

## Hardware

- **GPU**: AMD RX 7800 XT (Mesa RADV)
- **CPU**: AMD (microcode updates enabled)
- **Desktop**: Hyprland with Catppuccin theming

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