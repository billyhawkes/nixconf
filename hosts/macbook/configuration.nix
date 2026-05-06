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

  system.activationScripts.postActivation.text = ''
    install -d -m 0755 -o ${user} -g staff ${home}/.config/ghostty
    ln -sfn /etc/ghostty/config ${home}/.config/ghostty/config
    chown -h ${user}:staff ${home}/.config/ghostty/config
  '';

  system.stateVersion = 6;

  environment.etc."gitconfig".text = ''
    [user]
      email = "billyhawkes02@gmail.com"
      name = "Billy Hawkes"
  '';
}
