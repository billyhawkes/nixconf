{ pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };

    gamemode = {
      enable = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };

    gamescope = {
      enable = true;
      args = [ "--rt" "--prefer-vk-device" "1002:744c" ];
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;

  security.pam.loginLimits = [
    { domain = "*"; item = "nofile"; type = "soft"; value = "8192"; }
    { domain = "*"; item = "nofile"; type = "hard"; value = "1048576"; }
  ];

  environment.systemPackages = with pkgs; [
    steam-run
    mangohud
    protonup-qt
    radeontop
    lact
  ];

  systemd.packages = [ pkgs.lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
}