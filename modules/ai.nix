{ pkgs, ... }:

let
  qwenModel = "qwen3.6:35b-a3b";

  opencodeConfig = pkgs.writeText "opencode.json" ''
    {
      "$schema": "https://opencode.ai/config.json",
      "model": "ollama/${qwenModel}",
      "small_model": "ollama/${qwenModel}",
      "provider": {
        "ollama": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Ollama (local)",
          "options": {
            "baseURL": "http://localhost:11434/v1"
          },
          "models": {
            "${qwenModel}": {
              "name": "Qwen3.6 35B A3B (local)",
              "tools": true,
              "reasoning": false,
              "limit": {
                "context": 32768,
                "output": 8192
              }
            }
          }
        }
      }
    }
  '';
in
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
    loadModels = [ qwenModel ];
    environmentVariables = {
      HIP_VISIBLE_DEVICES = "0"; # only the 7800 XT
      ROCR_VISIBLE_DEVICES = "0"; # belt and suspenders
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_KEEP_ALIVE = "30m";
    };
  };

  environment.systemPackages = with pkgs; [
    ollama
    opencode
  ];

  systemd.tmpfiles.rules = [
    "d /home/billy/.config/opencode 0755 billy users -"
    "L+ /home/billy/.config/opencode/opencode.json - - - - ${opencodeConfig}"
  ];
}
