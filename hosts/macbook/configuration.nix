{ pkgs, ... }:

let
  user = "billyhawkes";
  home = "/Users/${user}";
  ghosttyConfig = pkgs.writeText "ghostty-config" ''
    font-family = JetBrains Mono
    font-size = 11
    theme = dark:catppuccin-mocha,light:catppuccin-latte
    window-padding-x = 8
    window-padding-y = 8
    shell-integration = bash
  '';
in
{
  nix.settings = {
    build-users-group = "nixbld";
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  users.users.${user}.home = home;

  programs = {
    bash.enable = true;
  };

  environment = {
    etc."ghostty/config".source = ghosttyConfig;
    systemPackages = with pkgs; [
      bun
      deadnix
      devenv
      fd
      gh
      ghostty-bin
      git
      jq
      lazygit
      nh
      nil
      nixfmt
      nodejs_24
      oxlint
      oxfmt
      pnpm
      prettierd
      ripgrep
      shellcheck
      statix
      tmux
      typescript
      typescript-language-server
      vscode-langservers-extracted
      yarn
    ];
  };

  system.activationScripts.postActivation.text = ''
    install -d -m 0755 -o ${user} -g staff ${home}/.config/ghostty
    ln -sfn /etc/ghostty/config ${home}/.config/ghostty/config
    chown -h ${user}:staff ${home}/.config/ghostty/config

    sudo -u ${user} HOME=${home} git config --global user.email "billyhawkes02@gmail.com"
    sudo -u ${user} HOME=${home} git config --global user.name "Billy Hawkes"
  '';

  system.stateVersion = 6;
}
