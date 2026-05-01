{ pkgs, ... }:

let
  ghosttyConfig = pkgs.writeText "ghostty-config" ''
    font-family = JetBrains Mono
    font-size = 11
    theme = dark:catppuccin-mocha,light:catppuccin-latte
    window-padding-x = 8
    window-padding-y = 8
    shell-integration = bash
  '';
in
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nvf = {
      enable = true;
      enableManpages = true;
      settings.vim = {
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;
        lineNumberMode = "relNumber";
        searchCase = "smart";
        preventJunkFiles = true;

        clipboard = {
          enable = true;
          providers.xclip.enable = true;
        };

        autocomplete.nvim-cmp.enable = true;
        autopairs.nvim-autopairs.enable = true;
        binds.whichKey.enable = true;
        comments.comment-nvim.enable = true;
        diagnostics.enable = true;
        filetree.nvimTree.enable = true;
        formatter.conform-nvim.enable = true;
        git = {
          enable = true;
          gitsigns.enable = true;
          vim-fugitive.enable = true;
        };
        lsp = {
          enable = true;
          inlayHints.enable = true;
          lspconfig.enable = true;
        };
        statusline.lualine.enable = true;
        telescope.enable = true;
        treesitter = {
          enable = true;
          context.enable = true;
        };

        languages = {
          bash.enable = true;
          css.enable = true;
          html.enable = true;
          lua.enable = true;
          markdown.enable = true;
          nix.enable = true;
          tailwind.enable = true;
          typescript = {
            enable = true;
            extensions.ts-error-translator.enable = true;
          };
        };
      };
    };
  };

  environment = {
    etc."ghostty/config".source = ghosttyConfig;
    systemPackages = with pkgs; [
      bun
      deadnix
      devenv
      fd
      gh
      ghostty
      jq
      lazygit
      nil
      nixfmt-rfc-style
      nodejs_24
      pnpm
      prettierd
      ripgrep
      shellcheck
      statix
      tmux
      typescript
      typescript-language-server
      vscode-langservers-extracted
      yarn
    ];
  };

  systemd.tmpfiles.rules = [
    "d /home/billy/.config 0755 billy users -"
    "d /home/billy/.config/ghostty 0755 billy users -"
    "L+ /home/billy/.config/ghostty/config - - - - /etc/ghostty/config"
  ];
}
