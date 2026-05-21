let
  user = "billyhawkes";
  home = "/Users/${user}";
in
{
  imports = [
    ../../modules/common.nix
    ../../modules/development.nix
  ];

  nix.settings.build-users-group = "nixbld";

  users.users.${user}.home = home;

  programs = {
    bash.enable = true;
  };

  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "rectangle"
      "google-chrome"
      "discord"
    ];
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      cmd + shift - 1 : open -a 'Google Chrome'
      cmd + shift - 2 : open -a 'Ghostty'
      cmd + shift - 3 : open -a 'Discord'
    '';
  };

  system.defaults.CustomUserPreferences."com.knollsoft.Rectangle" = {
    # Keybindings: keyCode 123=left, 124=right, 126=up
    # Modifiers: 1048576=cmd, 131072=shift, 786432=cmd+shift
    leftHalf = {
      keyCode = 123;
      modifierFlags = 1048576;
    };
    rightHalf = {
      keyCode = 124;
      modifierFlags = 1048576;
    };
    maximize = {
      keyCode = 126;
      modifierFlags = 1048576;
    };
  };

  system = {
    stateVersion = 6;
    primaryUser = user;
    activationScripts.postActivation.text = ''
      install -d -m 0755 -o ${user} -g staff ${home}/.config/ghostty
      ln -sfn /etc/ghostty/config ${home}/.config/ghostty/config
      chown -h ${user}:staff ${home}/.config/ghostty/config
    '';
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0; # no delay before hiding
        autohide-time-modifier = 0.0; # instant animation
        show-recents = false;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  environment.etc."gitconfig".text = ''
    [user]
      email = "billyhawkes02@gmail.com"
      name = "Billy Hawkes"
  '';
}
