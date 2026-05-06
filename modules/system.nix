{ pkgs, ... }:

{
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

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  console.keyMap = "us";

  nix = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
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
