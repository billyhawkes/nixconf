{ pkgs, ... }:
let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt7zIRkUAFBXXwF/HVAMR16UKA8nB8nOg96qbBzR0cU billyhawkes02@gmail.com";
in
{
  imports = [
    ./common.nix
  ];

  boot = {
    tmp.cleanOnBoot = true;
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
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
    openssh.authorizedKeys.keys = [ sshKey ];
  };

  users.users.root.openssh.authorizedKeys.keys = [ sshKey ];

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  console.keyMap = "us";

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings.auto-optimise-store = true;
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        email = "billyhawkes02@gmail.com";
        name = "Billy Hawkes";
      };
    };
  };
}
