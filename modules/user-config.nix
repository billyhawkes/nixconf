{ pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    name = "wallpaper.jpg";
    url = "https://images.unsplash.com/photo-1615389854084-0eec48c5c12d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
    hash = "sha256-4G5VJNj0v00/7IyCvCSB+jHrLBIcFS3weMjbPnJ+0OY=";
  };

  hyprlandConfig = pkgs.writeText "hyprland.conf" ''
    monitor=,preferred,auto,auto

    input {
      kb_layout=us
      follow_mouse=1
      touchpad {
        natural_scroll=false
      }
    }

    general {
      gaps_in=5
      gaps_out=10
      border_size=2
      col.active_border=rgba(cba6f7ee) rgba(89b4faee) 45deg
      col.inactive_border=rgba(595959aa)
      layout=dwindle
    }

    decoration {
      rounding=10
      blur {
        enabled=true
        size=3
        passes=1
      }
      shadow {
        enabled=true
        range=4
        render_power=3
        color=rgba(1a1a1aee)
      }
    }

    animations {
      enabled=true
      bezier=myBezier, 0.05, 0.9, 0.1, 1.05
      animation=windows, 1, 7, myBezier
      animation=windowsOut, 1, 7, default, popin 80%
      animation=border, 1, 10, default
      animation=borderangle, 1, 8, default
      animation=fade, 1, 7, default
      animation=workspaces, 1, 6, default
    }

    dwindle {
      pseudotile=true
      preserve_split=true
    }

    $mod=SUPER

    bind=$mod, Return, exec, kitty
    bind=$mod, Q, killactive,
    bind=$mod, M, exit,
    bind=$mod, E, exec, kitty yazi
    bind=$mod, V, togglefloating,
    bind=$mod, R, exec, wofi --show drun
    bind=$mod, P, pseudo,
    bind=$mod, J, togglesplit,
    bind=$mod, left, movefocus, l
    bind=$mod, right, movefocus, r
    bind=$mod, up, movefocus, u
    bind=$mod, down, movefocus, d
    bind=$mod, 1, workspace, 1
    bind=$mod, 2, workspace, 2
    bind=$mod, 3, workspace, 3
    bind=$mod, 4, workspace, 4
    bind=$mod, 5, workspace, 5
    bind=$mod, 6, workspace, 6
    bind=$mod, 7, workspace, 7
    bind=$mod, 8, workspace, 8
    bind=$mod, 9, workspace, 9
    bind=$mod, 0, workspace, 10
    bind=$mod SHIFT, 1, movetoworkspace, 1
    bind=$mod SHIFT, 2, movetoworkspace, 2
    bind=$mod SHIFT, 3, movetoworkspace, 3
    bind=$mod SHIFT, 4, movetoworkspace, 4
    bind=$mod SHIFT, 5, movetoworkspace, 5
    bind=$mod SHIFT, 6, movetoworkspace, 6
    bind=$mod SHIFT, 7, movetoworkspace, 7
    bind=$mod SHIFT, 8, movetoworkspace, 8
    bind=$mod SHIFT, 9, movetoworkspace, 9
    bind=$mod SHIFT, 0, movetoworkspace, 10
    bind=, Print, exec, grim -g "$(slurp)" - | wl-copy
    bind=SHIFT, Print, exec, grim - | wl-copy
    bind=$mod, L, exec, swaylock
    bind=$mod, B, exec, firefox
    bind=$mod, D, exec, discord

    bindm=$mod, mouse:272, movewindow
    bindm=$mod, mouse:273, resizewindow

    exec-once=waybar
    exec-once=mako
    exec-once=swww-daemon
    exec-once=sleep 1 && swww img ${wallpaper}

    windowrulev2 = float, class:^(pavucontrol)$
    windowrulev2 = float, class:^(wofi)$
  '';

  kittyConfig = pkgs.writeText "kitty.conf" ''
    font_family JetBrains Mono
    font_size 11
    background_opacity 0.95
    background #1e1e2e
    foreground #cdd6f4
    cursor #f5e0dc
    cursor_text_color #1e1e2e
    selection_background #353749
    color0 #45475a
    color8 #585b70
    color1 #f38ba8
    color9 #f38ba8
    color2 #a6e3a1
    color10 #a6e3a1
    color4 #89b4fa
    color12 #89b4fa
    color5 #f5c2e7
    color13 #f5c2e7
    enable_audio_bell no
    scrollback_lines 10000
    window_padding_width 4
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
    "hypr/hyprland.conf".source = hyprlandConfig;
    "kitty/kitty.conf".source = kittyConfig;
    "gitconfig".source = gitConfig;
  };

  systemd.tmpfiles.rules = [
    "d /home/billy/.config 0755 billy users -"
    "d /home/billy/.config/hypr 0755 billy users -"
    "d /home/billy/.config/kitty 0755 billy users -"
    "L+ /home/billy/.config/hypr/hyprland.conf - - - - /etc/hypr/hyprland.conf"
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