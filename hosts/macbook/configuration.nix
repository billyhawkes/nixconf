{ pkgs, ... }:
let
  user = "billyhawkes";
  home = "/Users/${user}";
  postgresql = pkgs.postgresql_18;
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

    zsh = {
      enable = true;
      interactiveShellInit = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
        eval "$(direnv hook zsh)"
      '';
    };
  };

  environment.systemPath = [
    "${home}/.bun/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  homebrew = {
    enable = true;
    brews = [
      "direnv" # TASK: Move to pkgs when build is fixed
      "odin"
      "sdl3"
      "pkg-config"
      "just"
    ];
    casks = [
      "ghostty"
      "steam"
      "google-chrome"
      "discord"
      "tailscale-app"
      "docker-desktop"
      "linearmouse"
      "moonlight"
      "rectangle"
    ];
    masApps = {
      Xcode = 497799835;
    };
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
    # Modifiers: 1048576=cmd, 131072=shift, 1179648=cmd+shift
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
    previousDisplay = {
      keyCode = 123;
      modifierFlags = 1179648;
    };
    nextDisplay = {
      keyCode = 124;
      modifierFlags = 1179648;
    };
  };

  system = {
    stateVersion = 6;
    primaryUser = user;
    activationScripts.postActivation.text = ''
      install -d -m 0755 -o ${user} -g staff ${home}/.config
      install -d -m 0755 -o ${user} -g staff ${home}/.config/ghostty
      ln -sfn /etc/ghostty/config ${home}/.config/ghostty/config
      chown -h ${user}:staff ${home}/.config/ghostty/config
      install -d -m 0755 -o ${user} -g staff ${home}/.config/opencode
      install -d -m 0755 -o ${user} -g staff ${home}/.config/gh
      install -d -m 0755 -o ${user} -g staff ${home}/.aws
      ln -sfn /etc/aws/config ${home}/.aws/config
      chown -h ${user}:staff ${home}/.aws/config
      ln -sfn /etc/bunfig.toml ${home}/.bunfig.toml
      chown -h ${user}:staff ${home}/.bunfig.toml
      printf '[user]\n  name = Billy Hawkes\n  email = billyhawkes02@gmail.com\n' > ${home}/.gitconfig
      chown ${user}:staff ${home}/.gitconfig
    '';
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        show-recents = false;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  environment.etc."aws/config".text = ''
    [default]
    sso_session = bhawkes@krakconsultants.com
    sso_account_id = 699475939168
    sso_role_name = AdministratorAccess
    region = ca-central-1

    [profile bhawkes@krakconsultants.com]
    sso_session = bhawkes@krakconsultants.com
    sso_account_id = 699475939168
    sso_role_name = AdministratorAccess
    region = ca-central-1

    [sso-session bhawkes@krakconsultants.com]
    sso_start_url = https://ssoins-8824190e0c2cdd70.portal.ca-central-1.app.aws
    sso_region = ca-central-1
    sso_registration_scopes = sso:account:access
  '';

  services.postgresql = {
    enable = true;
    package = postgresql;
    extraPlugins = with postgresql.pkgs; [
      postgis
      pgvector
    ];
    dataDir = "${home}/.local/share/postgresql/18";
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };
}
