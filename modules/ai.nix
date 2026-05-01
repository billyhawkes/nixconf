{ pkgs, ... }:

let
  defaultModel = "qwen3.5";

  models = {
    "qwen3.5" = {
      name = "Qwen3.5 9B";
      tools = true;
      reasoning = false;
      limit = {
        context = 32768;
        output = 8192;
      };
    };
    "qwen3.6:35b-a3b" = {
      name = "Qwen3.6 35B";
      tools = true;
      reasoning = false;
      limit = {
        context = 32768;
        output = 8192;
      };
    };
  };

  opencodeConfig = pkgs.writeText "opencode.json" ''
    ${builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      model = "ollama/${defaultModel}";
      small_model = "ollama/${defaultModel}";
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options = {
            baseURL = "http://localhost:11434/v1";
          };
          inherit models;
        };
      };
    }}
  '';
in
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
    loadModels = builtins.attrNames models;
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
    opencode
  ];

  systemd.tmpfiles.rules = [
    "d /home/billy/.config/opencode 0755 billy users -"
    "L+ /home/billy/.config/opencode/opencode.json - - - - ${opencodeConfig}"
  ];
}
