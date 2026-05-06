{
  lib,
  config,
  ...
}:
{
  options.preferences.tailscale = {
    # Enables Tailscale
    enable = lib.mkEnableOption "Tailscale";

    # Defines the tags of the Tailscale server
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Server tags";
    };

    # Defines the hostname of the Tailscale server
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Tailscale hostname";
    };

    ports = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "Tailscale ports";
    };
  };

  config = lib.mkIf config.preferences.tailscale.enable {
    sops.secrets.tailscale_key.sopsFile = ../secrets/default.enc.yaml;

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscale_key.path;
      openFirewall = true;
      extraUpFlags = [
        "--hostname=${config.preferences.tailscale.hostName}"
        "--ssh"
      ]
      ++ lib.optional (config.preferences.tailscale.tags != [ ]) (
        "--advertise-tags=" + lib.concatMapStringsSep "," (t: "tag:${t}") config.preferences.tailscale.tags
      );
    };

    networking.firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      interfaces.tailscale0.allowedTCPPorts = config.preferences.tailscale.ports;
    };
  };

}
