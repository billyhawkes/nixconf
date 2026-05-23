{ pkgs, ... }:
{
  imports = [
    ./neovim.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      # Tools
      opencode

      # Nix
      nh
      statix
      deadnix
      shellcheck

      # Typescrypt
      bun
      nodejs_24
      prettierd
      typescript
      typescript-language-server
      vscode-langservers-extracted

      # Rust
      cargo
      clippy
      rust-analyzer
      rustc
      rustfmt

      # CLI's
      awscli2
      lazygit
      gh
    ];
  };
}
