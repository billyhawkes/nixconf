{ pkgs, ... }:
let
  hostName = "desktop";
  opencodeWebPort = 4096;
  opencodeWebEnv = "/var/lib/opencode-web/opencode.env";
  opencodeConfig = import ../../modules/opencode.json.nix {
    baseURL = "http://127.0.0.1:11434/v1";
    server = {
      hostname = "0.0.0.0";
      port = opencodeWebPort;
    };
  };
  syncthingGuiPort = 8384;
  syncthingSyncPort = 22000;
in
{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
    ../../modules/system.nix
    ../../modules/desktop.nix
    ../../modules/ai.nix
    ../../modules/gaming.nix
    ../../modules/secrets.nix
    ../../modules/tailscale.nix
    ../../modules/development.nix
  ];

  networking.hostName = hostName;

  environment.sessionVariables.PATH = [ "/home/billy/.bun/bin" ];

  preferences = {
    tailscale = {
      inherit hostName;
      enable = true;
      ports = [
        11434
        opencodeWebPort
        syncthingGuiPort
        syncthingSyncPort
      ];
    };
  };

  networking.firewall.interfaces.tailscale0.allowedUDPPorts = [
    syncthingSyncPort
    21027
  ];

  environment.etc."opencode/opencode.jsonc".text = opencodeConfig;

  systemd.tmpfiles.rules = [
    "d /home/billy/Notes 0755 billy users -"
    "d /var/lib/opencode-web 0700 billy users -"
  ];

  services.syncthing = {
    enable = true;
    user = "billy";
    group = "users";
    dataDir = "/home/billy";
    configDir = "/home/billy/.config/syncthing";
    guiAddress = "0.0.0.0:${toString syncthingGuiPort}";
    openDefaultPorts = false;
    overrideDevices = false;
    overrideFolders = false;
  };

  systemd.services.opencode-web = {
    description = "OpenCode Web UI";
    after = [
      "network-online.target"
      "ollama.service"
      "tailscaled.service"
    ];
    wants = [
      "network-online.target"
      "ollama.service"
      "tailscaled.service"
    ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      OPENCODE_CONFIG = "/etc/opencode/opencode.jsonc";
      OPENCODE_SERVER_USERNAME = "billy";
    };
    serviceConfig = {
      User = "billy";
      Group = "users";
      WorkingDirectory = "/home/billy/Notes";
      EnvironmentFile = "-${opencodeWebEnv}";
      ExecCondition = "${pkgs.bash}/bin/bash -c 'test -n \"$$OPENCODE_SERVER_PASSWORD\" || { printf \"OPENCODE_SERVER_PASSWORD must be set in ${opencodeWebEnv}\\n\" >&2; exit 1; }'";
      ExecStart = "${pkgs.opencode}/bin/opencode web";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  users.users.billy = {
    isNormalUser = true;
    description = "Billy";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "input"
      "gamemode"
    ];
    shell = pkgs.bash;
    packages = with pkgs; [
      discord
      firefox
      ghostty
      opencode
      pavucontrol
      pamixer
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt7zIRkUAFBXXwF/HVAMR16UKA8nB8nOg96qbBzR0cU billyhawkes02@gmail.com"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt7zIRkUAFBXXwF/HVAMR16UKA8nB8nOg96qbBzR0cU billyhawkes02@gmail.com"
  ];

  system.activationScripts.bunfig.text = ''
    install -d -m 0755 -o billy -g users /home/billy
    ln -sfn /etc/bunfig.toml /home/billy/.bunfig.toml
    chown -h billy:users /home/billy/.bunfig.toml
    install -d -m 0755 -o billy -g users /home/billy/.config/opencode
    ln -sfn /etc/opencode/opencode.jsonc /home/billy/.config/opencode/opencode.jsonc
    chown -h billy:users /home/billy/.config/opencode/opencode.jsonc
  '';

  system.stateVersion = "24.11";
}
