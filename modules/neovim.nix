{ lib, pkgs, ... }:
{
  programs.nvf = {
    enable = true;
    enableManpages = true;
    settings.vim = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
      viAlias = true;
      vimAlias = true;
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
        shiftwidth = 4;
        splitbelow = true;
        splitright = true;
        softtabstop = 4;
        tabstop = 4;
        timeoutlen = 300;
        undofile = true;
        updatetime = 250;
      };

      extraPackages = with pkgs; [
        nixfmt
        oxlint
        oxfmt
        rustfmt
        statix
        stylua
        typos-lsp
      ];

      clipboard = {
        enable = true;
        registers = "unnamedplus";
        providers.xclip.enable = pkgs.stdenv.isLinux;
      };

      autocomplete.blink-cmp = {
        enable = true;
        setupOpts = {
          keymap.preset = "enter";
          completion.documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          sources.default = [
            "lsp"
            "path"
            "snippets"
          ];
        };
      };
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
            rust = [ "rustfmt" ];
            typescript = [ "oxfmt" ];
            typescriptreact = [ "oxfmt" ];
            yaml = [ "oxfmt" ];
          };
        };
      };
      git = {
        enable = true;
        vim-fugitive.enable = true;
      };
      lsp = {
        enable = true;
        inlayHints.enable = true;
        lspkind.enable = true;
        presets.tailwindcss-language-server.enable = true;
        presets.typescript-go.enable = true;
        servers = {
          ols = lib.mkIf pkgs.stdenv.isDarwin {
            cmd = lib.mkForce [ "/opt/homebrew/bin/ols" ];
            init_options = {
              odin_command = "/opt/homebrew/bin/odin";
            };
          };
          typos_lsp.enable = true;
        };
      };
      mini = {
        ai.enable = true;
        comment.enable = true;
        diff = {
          enable = true;
          setupOpts.view = {
            style = "sign";
            signs = {
              add = "+";
              change = "~";
              delete = "_";
            };
          };
        };
        pairs.enable = true;
        statusline.enable = true;
        surround.enable = true;
      };
      notes = {
        todo-comments = {
          enable = true;
          setupOpts.signs = false;
        };
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
            "build/"
            "dist/"
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
      lazy.plugins.telescope.keys = [
        {
          mode = "n";
          key = "<leader>s.";
          action = "function() require('telescope.builtin').oldfiles({ only_cwd = true }) end";
          lua = true;
          desc = ''[S]earch Recent Files ("." for repeat)'';
        }
      ];
      theme = {
        enable = true;
        name = "tokyonight";
        style = "night";
      };
      treesitter.context.enable = true;

      languages = {
        enableTreesitter = true;
        astro.enable = true;
        bash.enable = true;
        css.enable = true;
        docker.enable = true;
        html.enable = true;
        json.enable = true;
        lua.enable = true;
        markdown = {
          enable = true;
          lsp.servers = [ "markdown-oxide" ];
        };
        nix.enable = true;
        odin.enable = true;
        python.enable = true;
        rust.enable = true;
        tsx = {
          enable = true;
          lsp.enable = false;
        };
        typescript = {
          enable = true;
          extensions.ts-error-translator.enable = true;
          lsp.enable = false;
        };
        yaml.enable = true;
        zig.enable = true;
      };

      utility.oil-nvim = {
        enable = true;
        setupOpts = {
          default_file_explorer = true;
          view_options.show_hidden = true;
        };
      };
      utility.preview.markdownPreview.enable = true;

      augroups = [
        {
          name = "highlight-yank";
          clear = true;
        }
      ];

      autocmds = [
        {
          event = [ "TextYankPost" ];
          group = "highlight-yank";
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
}
