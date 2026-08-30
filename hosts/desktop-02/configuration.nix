_:
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

  services.k3s = {
    enable = true;
    role = "server";
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
  };

  system.stateVersion = "25.11";
}
