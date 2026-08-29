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
│   ├── system.nix                # Base system settings
│   ├── desktop.nix               # KDE Plasma, Pipewire, Bluetooth
│   ├── development.nix           # nvf Neovim, Bun, web tooling
│   ├── gaming.nix                # Steam, Gamemode, AMD optimizations
│   └── user-config.nix           # Kitty, Git, Bash configs
└── scripts/
    └── install.sh                # nixos-anywhere helper
```

## Apply config from Mac

```bash
nix shell nixpkgs/nixos-unstable#nh -c \
    nh os switch ".#desktop" \
    -- \
    --build-host "billy@<ip>" \
    --target-host "billy@<ip>" \
    --sudo
```

One command applies everything — system, desktop, development, gaming, and user configs.

## Apply desktop-02 config

```bash
nix shell nixpkgs/nixos-unstable#nh -c \
    nh os switch . \
    --hostname desktop-02 \
    --build-host "billy@10.0.0.56" \
    --target-host "billy@10.0.0.56" \
    --ask
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
