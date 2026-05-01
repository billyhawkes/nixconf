{
  lib,
  config,
  ...
}:
{
  options.preferences.tailscale = {
    enable = lib.mkEnableOption "Tailscale";
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Server tags";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Tailscale hostname";
    };
  };

  config = lib.mkIf config.preferences.tailscale.enable {
    sops.secrets.tailscale_key.sopsFile = ../secrets/default.enc.yaml;

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscale_key.path;
      extraUpFlags = [
        "--hostname=${config.preferences.tailscale.hostName}"
        "--ssh"
      ]
      ++ lib.optional (config.preferences.tailscale.tags != [ ]) (
        "--advertise-tags=" + lib.concatMapStringsSep "," (t: "tag:${t}") config.preferences.tailscale.tags
      );
    };
  };
}
