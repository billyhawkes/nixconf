# Personal NixOS Infrastructure

NixOS configuration for personal desktop.

## Structure

```
.
├── flake.nix                    # Entry point
├── hosts/
│   ├── desktop/                   # Desktop workstation
│   └── desktop-02/                # Headless server
├── modules/
│   ├── nixos.nix                 # Shared NixOS system configuration
│   ├── common.nix                # Packages shared by NixOS and macOS
│   ├── desktop.nix               # KDE Plasma, Pipewire, Bluetooth
│   ├── development.nix           # nvf Neovim, Bun, web tooling
│   ├── gaming.nix                # Steam, Gamemode, AMD optimizations
│   └── secrets.nix               # SOPS defaults
└── scripts/
    └── install.sh                # nixos-anywhere helper
```

## Apply config from Mac

```bash
nix shell nixpkgs/nixos-unstable#nh -c \
    nh os switch ".#desktop" \
    -- \
    --build-host "root@<ip>" \
    --target-host "root@<ip>"
```

One command applies everything — system, desktop, development, gaming, and user configs.

## Apply desktop-02 config

After the initial deployment has provisioned the root SSH key:

```bash
nix shell nixpkgs/nixos-unstable#nh -c \
    nh os switch . \
    --hostname desktop-02 \
    --build-host "root@10.0.0.56" \
    --target-host "root@10.0.0.56"
```

After the first deployment, enroll the server in Tailscale:

```bash
ssh billy@10.0.0.56
sudo tailscale up --ssh --hostname=desktop-02
```

## Apply MacBook config

```bash
nix shell nixpkgs/nixos-unstable#nh -c nh darwin switch ".#macbook"
```

## Useful Commands

```bash
nix flake update    # Update flake inputs
nix flake check      # Check flake
```

## Hardware

- **GPU**: AMD RX 7800 XT (Mesa RADV)
- **CPU**: AMD (microcode updates enabled)
- **Desktop**: KDE Plasma on X11
