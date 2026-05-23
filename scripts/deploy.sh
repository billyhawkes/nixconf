nix shell nixpkgs/nixos-unstable#nh -c \
  nh os switch . \
  --hostname desktop \
  --build-host "billy@desktop" \
  --target-host "billy@desktop" \
  --ask
