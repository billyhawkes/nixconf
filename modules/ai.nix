{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "0.0.0.0";
    port = 11434;
    environmentVariables = {
      HIP_VISIBLE_DEVICES = "0"; # only the 7800 XT
      ROCR_VISIBLE_DEVICES = "0"; # belt and suspenders
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_KEEP_ALIVE = "30m";
      OLLAMA_CONTEXT_LENGTH = "32768";
    };
  };

  environment.systemPackages = with pkgs; [
    ollama
  ];

}
