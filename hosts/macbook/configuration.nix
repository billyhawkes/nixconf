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
    install -d -m 0755 -o ${user} -g staff ${home}/.aws
    ln -sfn /etc/aws/config ${home}/.aws/config
    chown -h ${user}:staff ${home}/.aws/config
  '';

  system.stateVersion = 6;

  environment.etc."gitconfig".text = ''
    [user]
      email = "billyhawkes02@gmail.com"
      name = "Billy Hawkes"
  '';

  environment.etc."aws/config".text = ''
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
}
