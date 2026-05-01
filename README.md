# Personal NixOS Infrastructure

NixOS configuration for personal desktop.

## Structure

```
.
├── flake.nix                    # Entry point
├── hosts/desktop/
│   ├── configuration.nix         # Host config
│   └── hardware.nix              # Hardware config (auto-generated)
├── modules/
│   ├── system.nix                # Base system settings
│   ├── desktop.nix               # KDE Plasma, Pipewire, Bluetooth
│   ├── development.nix           # Ghostty, nvf Neovim, Bun, web tooling
│   ├── gaming.nix                # Steam, Gamemode, AMD optimizations
│   └── user-config.nix           # Kitty, Git, Bash configs
└── scripts/
    └── install.sh                # nixos-anywhere helper
```

## Apply config from Mac

```bash
nix shell nixpkgs/nixos-unstable#nixos-rebuild -c \
    nixos-rebuild --no-reexec switch \
    --flake ".#desktop" \
    --build-host "billy@<ip>" \
    --target-host "billy@<ip>" \
    --sudo
```

One command applies everything — system, desktop, development, gaming, and user configs.

## Useful Commands

```bash
nix flake update    # Update flake inputs
nix flake check      # Check flake
```

## Hardware

- **GPU**: AMD RX 7800 XT (Mesa RADV)
- **CPU**: AMD (microcode updates enabled)
- **Desktop**: KDE Plasma on X11
