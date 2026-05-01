{ config, ... }:

{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ../../secrets/default.enc.yaml;
    defaultSopsFormat = "yaml";
    secrets.example_key = {};
  };
}