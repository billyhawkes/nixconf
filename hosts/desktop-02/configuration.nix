{ pkgs, ... }:
let
  hostName = "desktop-02";
in
{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
    ../../modules/system.nix
  ];

  networking.hostName = hostName;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  users.users.billy = {
    isNormalUser = true;
    description = "Billy";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt7zIRkUAFBXXwF/HVAMR16UKA8nB8nOg96qbBzR0cU billyhawkes02@gmail.com"
    ];
  };

  services.openssh.settings.PasswordAuthentication = false;

  system.stateVersion = "25.11";
}
