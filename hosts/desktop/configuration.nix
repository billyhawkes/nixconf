{ pkgs, ... }:
let
  hostName = "desktop";
in
{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
    ../../modules/system.nix
    ../../modules/desktop.nix
    ../../modules/ai.nix
    ../../modules/gaming.nix
    ../../modules/secrets.nix
    ../../modules/tailscale.nix
    ../../modules/development.nix
  ];

  networking.hostName = hostName;

  environment.sessionVariables.PATH = [ "/home/billy/.bun/bin" ];

  preferences = {
    tailscale = {
      inherit hostName;
      enable = true;
      ports = [ 11434 ];
    };
  };

  users.users.billy = {
    isNormalUser = true;
    description = "Billy";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "input"
      "gamemode"
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      discord
      firefox
      ghostty
      pavucontrol
      pamixer
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt7zIRkUAFBXXwF/HVAMR16UKA8nB8nOg96qbBzR0cU billyhawkes02@gmail.com"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt7zIRkUAFBXXwF/HVAMR16UKA8nB8nOg96qbBzR0cU billyhawkes02@gmail.com"
  ];

  system.activationScripts.bunfig.text = ''
    install -d -m 0755 -o billy -g users /home/billy
    ln -sfn /etc/bunfig.toml /home/billy/.bunfig.toml
    chown -h billy:users /home/billy/.bunfig.toml
  '';

  system.stateVersion = "24.11";
}
