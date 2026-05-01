{ pkgs, ... }:

{
  home.username = "billy";
  home.homeDirectory = "/home/billy";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    kitty
    tmux
    discord
    firefox
    waybar
    wofi
    swww
    swaylock-effects
    wlogout
    mako
    wl-clipboard
    yazi
    fastfetch
    eza
    fzf
    ripgrep
    fd
    pavucontrol
    pamixer
    grim
    slurp
    catppuccin-cursors.mochaDark
    papirus-icon-theme
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      monitor = ",preferred,auto,auto";

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = false;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(cba6f7ee) rgba(89b4faee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = { enabled = true; size = 3; passes = 1; };
        shadow = { enabled = true; range = 4; render_power = 3; color = "rgba(1a1a1aee)"; };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = { pseudotile = true; preserve_split = true; };
      gestures.workspace_swipe = false;

      "$mod" = "SUPER";

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, kitty yazi"
        "$mod, V, togglefloating,"
        "$mod, R, exec, wofi --show drun"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print, exec, grim - | wl-copy"
        "$mod, L, exec, swaylock"
        "$mod, B, exec, firefox"
        "$mod, D, exec, discord"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      exec-once = [
        "waybar"
        "mako"
        "swww init"
        "swww img ~/Pictures/wallpaper.png"
      ];

      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(wofi)$"
      ];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrains Mono";
      font_size = 11;
      background_opacity = "0.95";
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      selection_background = "#353749";
      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      enable_audio_bell = false;
      scrollback_lines = 10000;
      window_padding_width = 4;
      confirm_os_window_close = 0;
    };
  };

  programs.git = {
    enable = true;
    userName = "Billy";
    userEmail = "your@email.com";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "eza -la";
      la = "eza -a";
      l = "eza";
      cat = "bat";
      gs = "git status";
      gc = "git commit";
      gp = "git push";
    };
  };

  programs.home-manager.enable = true;
}