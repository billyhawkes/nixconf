#!/usr/bin/env bash
# Generate age public key from the desktop's SSH host key
# Run this when setting up a new host or after re-provisioning
ssh-keyscan 192.168.2.245 2>/dev/null | grep ed25519 | nix-shell -p ssh-to-age --run "ssh-to-age"