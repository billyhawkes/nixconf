{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/user-config.nix
    ../../modules/secrets.nix
    ../../modules/tailscale.nix
  ];

  networking.hostName = "desktop";

  preferences = {
    tailscale.enable = true;
    tailscale.hostName = "desktop";
  };

  users.users.billy = {
    isNormalUser = true;
    description = "Billy";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "gamemode"
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      kitty
      tmux
      discord
      firefox
      waybar
      wofi
      awww
      swaylock-effects
      wlogout
      mako
      wl-clipboard
      yazi
      bat
      fastfetch
      eza
      fzf
      ripgrep
      fd
      pavucontrol
      pamixer
      grim
      slurp
      catppuccin
      papirus-icon-theme
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJs3L3ILSlszfrfdIql6BoMzUwvHxqvykpLCIkFg4/+K billyhawkes02@gmail.com"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJs3L3ILSlszfrfdIql6BoMzUwvHxqvykpLCIkFg4/+K billyhawkes02@gmail.com"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
