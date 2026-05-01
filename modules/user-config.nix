{ pkgs, ... }:

let
  kittyConfig = pkgs.writeText "kitty.conf" ''
    font_family JetBrains Mono
    font_size 11
    enable_audio_bell no
    scrollback_lines 10000
    confirm_os_window_close 0
  '';

  gitConfig = pkgs.writeText "gitconfig" ''
    [user]
        name = Billy
        email = your@email.com
  '';
in
{
  environment.etc = {
    "kitty/kitty.conf".source = kittyConfig;
    "gitconfig".source = gitConfig;
  };

  systemd.tmpfiles.rules = [
    "d /home/billy/.config 0755 billy users -"
    "d /home/billy/.config/kitty 0755 billy users -"
    "L+ /home/billy/.config/kitty/kitty.conf - - - - /etc/kitty/kitty.conf"
  ];

  environment.interactiveShellInit = ''
    alias ll='eza -la'
    alias la='eza -a'
    alias l='eza'
    alias cat='bat'
    alias gs='git status'
    alias gc='git commit'
    alias gp='git push'
  '';
}
