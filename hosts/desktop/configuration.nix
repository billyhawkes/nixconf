{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
  ];

  networking.hostName = "desktop";

  users.users.billy = {
    isNormalUser = true;
    description = "Billy";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "gamemode" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJs3L3ILSlszfrfdIql6BoMzUwvHxqvykpLCIkFg4/+K billyhawkes02@gmail.com"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJs3L3ILSlszfrfdIql6BoMzUwvHxqvykpLCIkFg4/+K billyhawkes02@gmail.com"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}