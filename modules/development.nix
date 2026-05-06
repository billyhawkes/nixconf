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
    git = {
      enable = true;
      config = {
        user = {
          email = "billyhawkes02@gmail.com";
          name = "Billy Hawkes";
        };
      };
    };

    nvf = {
      enable = true;
      enableManpages = true;
      settings.vim = {
        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;
        lineNumberMode = "number";
        searchCase = "smart";
        preventJunkFiles = true;

        options = {
          breakindent = true;
          confirm = true;
          cursorline = true;
          inccommand = "split";
          list = true;
          listchars = "tab:» ,trail:·,nbsp:␣";
          mouse = "a";
          scrolloff = 10;
          showmode = false;
          signcolumn = "yes";
          splitbelow = true;
          splitright = true;
          timeoutlen = 300;
          undofile = true;
          updatetime = 250;
        };

        extraPackages = with pkgs; [
          astro-language-server
          dockerfile-language-server
          nil
          nixfmt
          oxlint
          oxfmt
          python313Packages.python-lsp-server
          statix
          stylua
          tailwindcss-language-server
          typos-lsp
          typescript
          yaml-language-server
        ];

        clipboard = {
          enable = true;
          providers.xclip.enable = true;
        };

        autocomplete.blink-cmp = {
          enable = true;
          setupOpts = {
            keymap.preset = "enter";
            completion.documentation = {
              auto_show = true;
              auto_show_delay_ms = 200;
            };
            fuzzy.implementation = "lua";
            sources.default = [
              "lsp"
              "path"
              "snippets"
            ];
          };
        };
        autopairs.nvim-autopairs.enable = true;
        binds.whichKey = {
          enable = true;
          setupOpts = {
            delay = 0;
            icons.mappings = true;
            spec = [
              {
                "@1" = "<leader>s";
                group = "[S]earch";
              }
              {
                "@1" = "<leader>t";
                group = "[T]oggle";
              }
              {
                "@1" = "<leader>h";
                group = "Git [H]unk";
              }
              {
                "@1" = "gr";
                group = "LSP Actions";
              }
            ];
          };
        };
        comments.comment-nvim.enable = true;
        diagnostics = {
          enable = true;
          config = {
            update_in_insert = false;
            severity_sort = true;
            virtual_text = true;
            virtual_lines = false;
            float = {
              border = "rounded";
              source = "if_many";
            };
          };
          nvim-lint = {
            enable = true;
            linters_by_ft = {
              javascript = [ "oxlint" ];
              json = [ "oxlint" ];
              nix = [ "statix" ];
              typescript = [ "oxlint" ];
              typescriptreact = [ "oxlint" ];
            };
          };
        };
        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            notify_on_error = false;
            format_on_save = {
              timeout_ms = 500;
              lsp_format = "fallback";
            };
            formatters_by_ft = {
              javascript = [ "oxfmt" ];
              json = [ "oxfmt" ];
              lua = [ "stylua" ];
              markdown = [ "oxfmt" ];
              nix = [ "nixfmt" ];
              typescript = [ "oxfmt" ];
              typescriptreact = [ "oxfmt" ];
              yaml = [ "oxfmt" ];
            };
          };
        };
        git = {
          enable = true;
          gitsigns = {
            enable = true;
            setupOpts.signs = {
              add.text = "+";
              change.text = "~";
              delete.text = "_";
              topdelete.text = "‾";
              changedelete.text = "~";
            };
          };
          vim-fugitive.enable = true;
        };
        lsp = {
          enable = true;
          inlayHints.enable = true;
          lspkind.enable = true;
          lspconfig.enable = true;
          presets.tailwindcss-language-server.enable = true;
          servers.typos_lsp.enable = true;
        };
        mini = {
          ai = {
            enable = true;
            setupOpts.n_lines = 500;
          };
          statusline.enable = true;
          surround.enable = true;
        };
        notes.todo-comments = {
          enable = true;
          setupOpts.signs = false;
        };
        telescope = {
          enable = true;
          mappings = {
            buffers = "<leader><leader>";
            diagnostics = "<leader>sd";
            findFiles = "<leader>sf";
            helpTags = "<leader>sh";
            liveGrep = "<leader>sg";
            lspDefinitions = "grd";
            lspDocumentSymbols = "gO";
            lspImplementations = "gri";
            lspReferences = "grr";
            lspTypeDefinitions = "grt";
            lspWorkspaceSymbols = "gW";
            resume = "<leader>sr";
          };
          setupOpts = {
            defaults.file_ignore_patterns = [
              "node_modules/"
              ".agents/"
              "/build/"
              "/dist/"
              "bun%.lock"
              "%.git/"
            ];
            pickers = {
              find_files.hidden = true;
              grep_string.hidden = true;
              live_grep.hidden = true;
            };
          };
        };
        theme = {
          enable = true;
          name = "tokyonight";
          style = "night";
        };
        treesitter = {
          enable = true;
          context.enable = true;
        };

        languages = {
          astro.enable = true;
          bash.enable = true;
          css.enable = true;
          html.enable = true;
          json.enable = true;
          lua.enable = true;
          markdown.enable = true;
          nix.enable = true;
          python.enable = true;
          typescript = {
            enable = true;
            extensions.ts-error-translator.enable = true;
            lsp.enable = false;
          };
          yaml.enable = true;
        };

        utility.oil-nvim = {
          enable = true;
          setupOpts = {
            default_file_explorer = true;
            view_options.show_hidden = true;
          };
        };

        augroups = [
          {
            name = "kickstart-highlight-yank";
            clear = true;
          }
        ];

        autocmds = [
          {
            event = [ "TextYankPost" ];
            group = "kickstart-highlight-yank";
            command = "lua vim.hl.on_yank()";
            desc = "Highlight when yanking (copying) text";
          }
        ];

        keymaps = [
          {
            mode = "n";
            key = "<Esc>";
            action = "<cmd>nohlsearch<CR>";
            desc = "Clear search highlight";
          }
          {
            mode = "n";
            key = "<leader>q";
            action = "vim.diagnostic.setloclist";
            lua = true;
            desc = "Open diagnostic quickfix list";
          }
          {
            mode = "t";
            key = "<Esc><Esc>";
            action = "<C-\\><C-n>";
            desc = "Exit terminal mode";
          }
          {
            mode = "n";
            key = "<C-h>";
            action = "<C-w><C-h>";
            desc = "Move focus to the left window";
          }
          {
            mode = "n";
            key = "<C-l>";
            action = "<C-w><C-l>";
            desc = "Move focus to the right window";
          }
          {
            mode = "n";
            key = "<C-j>";
            action = "<C-w><C-j>";
            desc = "Move focus to the lower window";
          }
          {
            mode = "n";
            key = "<C-k>";
            action = "<C-w><C-k>";
            desc = "Move focus to the upper window";
          }
          {
            mode = "n";
            key = "-";
            action = "<cmd>Oil<CR>";
            desc = "Open parent directory";
          }
          {
            mode = "n";
            key = "<leader>f";
            action = "function() require('conform').format { async = true, lsp_format = 'fallback' } end";
            lua = true;
            desc = "Format buffer";
          }
        ];
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
      nh
      nil
      nixfmt
      nodejs_24
      oxlint
      oxfmt
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
