{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SOPS_EDITOR = "nvim";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    btop
    age
    sops
  ];

}
