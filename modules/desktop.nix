{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      xkb.options = "caps:escape";
    };

    displayManager.sddm.enable = true;

    displayManager.defaultSession = "plasmax11";

    displayManager.autoLogin = {
      enable = true;
      user = "billy";
    };

    desktopManager.plasma6.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    blueman.enable = true;

    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };

    logind.settings.Login.IdleAction = "ignore";
  };

  environment.systemPackages = with pkgs; [ openrgb ];

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  systemd.services.openrgb-off = {
    description = "Turn desktop RGB LEDs off";
    after = [ "openrgb.service" ];
    wants = [ "openrgb.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "openrgb-off" ''
        for attempt in $(seq 1 30); do
          if ${pkgs.openrgb}/bin/openrgb --device 0 --mode Off \
            && ${pkgs.openrgb}/bin/openrgb --device 1 --mode Off \
            && ${pkgs.openrgb}/bin/openrgb --device 2 --mode Off; then
            exit 0
          fi

          sleep 1
        done

        exit 1
      '';
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.i2c.enable = true;

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  security.polkit.enable = true;
}
