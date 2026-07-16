{
  baseURL,
  server ? null,
}:
let
  modelLimit = {
    context = 32768;
    output = 16384;
  };
in
builtins.toJSON (
  {
    "$schema" = "https://opencode.ai/config.json";
    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (desktop)";
        options = {
          inherit baseURL;
        };
        models = {
          "qwen3.6:35b-a3b" = {
            name = "Qwen 3.6 35B A3B";
            limit = modelLimit;
          };
          "qwen3.5:latest" = {
            name = "Qwen 3.5";
            limit = modelLimit;
          };
        };
      };
      openai = {
        npm = "@ai-sdk/openai";
        name = "OpenAI";
      };
    };
    mcp = {
      localhost = {
        type = "remote";
        url = "http://localhost:3000/api/mcp";
        enabled = true;
      };
      shadcn = {
        type = "local";
        command = [
          "npx"
          "shadcn@latest"
          "mcp"
        ];
        enabled = true;
      };
    };
    references = {
      effect = {
        repository = "effect-TS/effect-smol";
        branch = "main";
        description = "Use for effect based code: httpapi, services, atom, etc";
      };
      "better-auth" = {
        repository = "better-auth/better-auth";
        branch = "main";
        description = "Used for authentication, login, sessions, users, organizations, etc";
      };
    };
  }
  // (if server == null then { } else { inherit server; })
)
