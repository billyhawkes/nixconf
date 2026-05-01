nix shell nixpkgs/nixos-unstable#nixos-rebuild -c \
    nixos-rebuild --no-reexec switch \
    --flake ".#desktop" \
    --build-host "billy@192.168.2.245" \
    --target-host "billy@192.168.2.245" \
    --ask-sudo-password
