{ pkgs, ... }:
{
  imports = [
    ./neovim.nix
  ];

  environment = {
    etc."bunfig.toml".text = ''
      [install]
      minimumReleaseAge = 259200
    '';

    systemPackages = with pkgs; [
      mysql84

      # Nix
      nh
      statix
      deadnix
      shellcheck
      cmake

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

      # Zig
      zig

      # CLI's
      awscli2
      lazygit
      gh
    ];
  };
}
