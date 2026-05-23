# AGENTS.md

Guidance for agents and automation working in this Nix configuration repo.

## Project Shape

This repo is a personal flake-based Nix configuration.

- `flake.nix` is the entry point.
- `nixosConfigurations.desktop` builds the Linux desktop host.
- `darwinConfigurations.macbook` builds the macOS/nix-darwin host.
- `hosts/desktop/configuration.nix` composes the desktop host.
- `hosts/macbook/configuration.nix` composes the MacBook host.
- `modules/*.nix` contains reusable configuration modules.
- `secrets/default.enc.yaml` is encrypted with SOPS and must stay encrypted.
- `scripts/*.sh` contains convenience deployment and setup commands.

## Mutation Rules

Make the smallest correct change. Prefer editing an existing module over adding a new abstraction.

Use these locations for common changes:

- Shared baseline settings and packages: `modules/common.nix`
- Development tools, language servers, CLIs, and Neovim import wiring: `modules/development.nix`
- Neovim and nvf configuration: `modules/neovim.nix`
- Linux desktop UI, audio, Bluetooth, display, and fonts: `modules/desktop.nix`
- Linux base system, SSH, firewall, Git, locale, and Nix GC: `modules/system.nix`
- Gaming, Steam, GameMode, Gamescope, kernel package, and GPU tuning: `modules/gaming.nix`
- Ollama and local AI services: `modules/ai.nix`
- Tailscale options and service wiring: `modules/tailscale.nix`
- SOPS setup only: `modules/secrets.nix`
- Desktop-only user packages and groups: `hosts/desktop/configuration.nix`
- Mac-only Homebrew casks, skhd bindings, macOS defaults, and Darwin services: `hosts/macbook/configuration.nix`

If a feature should be reusable, create `modules/<feature>.nix` and import it explicitly from the host that needs it. Do not import a module globally unless both hosts should receive it.

## Simple Change Recipes

Add a package to both machines:

1. Add it to `environment.systemPackages` in `modules/common.nix`.
2. Run `nixfmt modules/common.nix`.
3. Run `nix flake check`.

Add a development package:

1. Add it to `environment.systemPackages` in `modules/development.nix`.
2. Keep packages grouped by purpose when possible.
3. Run `nixfmt modules/development.nix`.
4. Run `nix flake check`.

Add a desktop-only Linux package:

1. Add it to `users.users.billy.packages` in `hosts/desktop/configuration.nix` if it is user-facing.
2. Add it to a relevant `modules/*.nix` package list if it is part of a feature area.
3. Run `nixfmt` on the changed file.
4. Run `nix flake check`.

Add a Mac app:

1. Add CLI tools to `homebrew.brews` or GUI apps to `homebrew.casks` in `hosts/macbook/configuration.nix` when they are Homebrew-managed.
2. Prefer Nix packages in `modules/common.nix` or `modules/development.nix` when they build reliably on Darwin.
3. Run `nixfmt hosts/macbook/configuration.nix`.
4. Run `nix flake check`.

Enable a feature on one host:

1. Put reusable implementation in `modules/<feature>.nix`.
2. Import it from only the relevant `hosts/<host>/configuration.nix`.
3. If the feature needs simple knobs, expose them under `options.preferences.<feature>` like `modules/tailscale.nix`.
4. Set host-specific values in the host configuration.

Change Tailscale settings:

1. Edit `preferences.tailscale` in `hosts/desktop/configuration.nix` for host-level values.
2. Edit `modules/tailscale.nix` only when changing the reusable Tailscale behavior.
3. Keep secrets referenced through SOPS paths; do not inline auth keys.

## Verification

Use the narrowest useful verification first, then the full flake check.

- Format a Nix file: `nixfmt path/to/file.nix`
- Check the flake: `nix flake check`
- Build or switch desktop: `nix shell nixpkgs/nixos-unstable#nh -c nh os switch ".#desktop"`
- Build or switch MacBook: `nix shell nixpkgs/nixos-unstable#nh -c nh darwin switch ".#macbook"`
- Existing desktop deploy helper: `./scripts/deploy.sh`
- Existing MacBook helper: `./scripts/macbook.sh`

Do not run switch/deploy commands unless the user asks or the task clearly requires applying the system configuration. `nix flake check` is usually enough for validation.

## Safety Rules

- Never commit or write plaintext secrets.
- Do not decrypt or edit `secrets/default.enc.yaml` unless explicitly asked.
- Keep `secrets/default.enc.yaml` encrypted and managed by SOPS.
- Do not modify `.sops.yaml` unless changing recipient policy intentionally.
- Do not edit `hosts/desktop/hardware.nix` unless hardware changed or the user asks.
- Preserve `system.stateVersion` values unless the user explicitly requests a state version migration.
- Keep Linux-only settings out of the Darwin host and Darwin-only settings out of NixOS modules imported by Linux.
- Avoid broad rewrites, compatibility shims, or new helper modules without a concrete need.
- Do not remove user packages, SSH keys, service settings, or firewall ports unless the user asks.

## Style

- Use `nixfmt` formatting.
- Keep package lists alphabetized only when the surrounding list already follows that style; otherwise preserve local grouping.
- Prefer explicit imports in host files over implicit global behavior.
- Keep comments short and useful.
- Match existing Nix style: simple attribute sets, direct module imports, and `with pkgs; [ ... ]` for package lists.
- For simple toggles, prefer typed options under `preferences.*` and host-level values.

## Git

- Do not create commits unless explicitly asked.
- Do not revert unrelated user changes.
- Before committing, inspect status, staged changes, unstaged changes, and recent commit style.
