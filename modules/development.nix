{ pkgs, ... }:
{
  imports = [
    ./neovim.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      opencode

      # Nix
      nh
      nil
      nixfmt
      statix

      # Software
      bun
      lazygit
      nodejs_24
      oxlint
      oxfmt
      prettierd

      deadnix
      fd
      gh
      jq
      ripgrep
      shellcheck
      typescript
      typescript-language-server
      vscode-langservers-extracted
    ];
  };
}
