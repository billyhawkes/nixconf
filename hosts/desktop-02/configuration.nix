{ config, lib, pkgs, ... }:
let
  hostName = "desktop-02";
in
{
  imports = [
    ./hardware.nix
    ../../modules/nixos.nix
  ];

  networking.hostName = hostName;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/srv/data" = {
      device = "/dev/disk/by-uuid/e12cab86-45a3-4e4f-b4bb-e20a231f0cc3";
      fsType = "ext4";
      options = [ "nofail" ];
    };
    "/srv/cache" = {
      device = "/dev/disk/by-uuid/084e0aad-0fb3-47c3-88c7-fd02a392c09e";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  systemd.services.media-directories = {
    description = "Create media server storage directories";
    after = [
      "srv-cache.mount"
      "srv-data.mount"
    ];
    requires = [
      "srv-cache.mount"
      "srv-data.mount"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/install -d -m 0775 -o billy -g users /srv/appdata /srv/appdata/bazarr /srv/appdata/gluetun /srv/appdata/jellyfin /srv/appdata/jellyseerr /srv/appdata/prowlarr /srv/appdata/qbittorrent /srv/appdata/radarr /srv/appdata/sonarr /srv/cache/jellyfin /srv/data/media /srv/data/media/movies /srv/data/media/tv /srv/data/torrents /srv/data/torrents/complete /srv/data/torrents/incomplete";
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      branch = "legacy_580";
      open = false;
    };
    nvidia-container-toolkit.enable = true;
  };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--secrets-encryption"
      "--kube-proxy-arg=nodeport-addresses=100.87.83.80/32"
    ];
  };

  systemd.services.k3s = {
    path = [ (lib.getOutput "tools" config.hardware.nvidia-container-toolkit.package) ];
    requires = [ "nvidia-container-toolkit-cdi-generator.service" ];
    after = [ "nvidia-container-toolkit-cdi-generator.service" ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      6443
      10250
    ];
    allowedUDPPorts = [ 8472 ];
    trustedInterfaces = [
      "cni0"
      "flannel.1"
    ];
    interfaces.tailscale0.allowedTCPPorts = [
      30676
      30696
      30787
      30808
      30989
    ];
  };

  system.stateVersion = "25.11";
}
