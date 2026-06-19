nix shell nixpkgs/nixos-unstable#nh -c \
  nh os switch . \
  --hostname desktop \
  --build-host "billy@10.0.0.91" \
  --target-host "billy@10.0.0.91" \
  --ask
