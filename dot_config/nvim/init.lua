-- ==========================================================================
-- Modern Neovim Configuration (kickstart-style)
-- Managed by chezmoi
-- ==========================================================================

-- --------------------------------------------------------------------------
-- Options
-- --------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.ruby_host_prog = "/opt/homebrew/lib/ruby/gems/4.0.0/bin/neovim-ruby-host"

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.showmode = false -- lualine shows mode
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 10
opt.hlsearch = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.termguicolors = true
opt.wrap = false
opt.fillchars = { eob = " " }

-- --------------------------------------------------------------------------
-- Keymaps (non-plugin)
-- --------------------------------------------------------------------------
local map = vim.keymap.set

-- Clear search highlight on Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })

-- Window navigation
map("n", "<C-h>", "<C-w><C-h>", { desc = "Focus left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Focus right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Focus upper window" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- --------------------------------------------------------------------------
-- Autocommands
-- --------------------------------------------------------------------------
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("restore-cursor", { clear = true }),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- --------------------------------------------------------------------------
-- Bootstrap lazy.nvim
-- --------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- --------------------------------------------------------------------------
-- Plugins
-- --------------------------------------------------------------------------
require("lazy").setup({

  -- ========== Theme ==========
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        mason = true,
        mini = true,
        native_lsp = { enabled = true },
        neotree = true,
        noice = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ========== UI ==========
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>x", group = "Diagnostics" },
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "j-hui/fidget.nvim",
    opts = {},
  },

  -- ========== Navigation ==========
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Find by grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      map("n", "<leader>fw", builtin.grep_string, { desc = "Find current word" })
      map("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
      map("n", "<leader>fr", builtin.resume, { desc = "Find resume" })
      map("n", "<leader>fo", builtin.oldfiles, { desc = "Find recent files" })
      map("n", "<leader><leader>", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- ========== Treesitter ==========
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "diff",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "html",
        "javascript",
        "json",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>a"] = "@parameter.inner" },
            swap_previous = { ["<leader>A"] = "@parameter.inner" },
          },
        },
      })
    end,
  },

  -- ========== LSP ==========
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          local lsp_map = function(keys, func, desc)
            map("n", keys, func, { buffer = buf, desc = "LSP: " .. desc })
          end

          local builtin = require("telescope.builtin")
          lsp_map("gd", builtin.lsp_definitions, "Go to definition")
          lsp_map("gr", builtin.lsp_references, "Go to references")
          lsp_map("gi", builtin.lsp_implementations, "Go to implementation")
          lsp_map("gy", builtin.lsp_type_definitions, "Go to type definition")
          lsp_map("<leader>cs", builtin.lsp_document_symbols, "Document symbols")
          lsp_map("<leader>cS", builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
          lsp_map("<leader>cr", vim.lsp.buf.rename, "Rename")
          lsp_map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          lsp_map("K", vim.lsp.buf.hover, "Hover documentation")
          lsp_map("gD", vim.lsp.buf.declaration, "Go to declaration")

          -- Highlight references under cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = buf,
              group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = buf,
              group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
            autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = ev.buf })
              end,
            })
          end

          -- Inlay hints toggle
          if client and client:supports_method("textDocument/inlayHint") then
            lsp_map("<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
            end, "Toggle inlay hints")
          end
        end,
      })

      -- Server configurations
      local servers = {
        pyright = {},
        gopls = {
          settings = {
            gopls = {
              analyses = { unusedparams = true },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
              },
              completion = { callSnippet = "Replace" },
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },
        bashls = {},
        jsonls = {},
        yamlls = {},
        taplo = {}, -- TOML
      }

      -- Tools to auto-install (formatters, linters)
      require("mason-tool-installer").setup({
        ensure_installed = {
          "pyright",
          "gopls",
          "lua-language-server",
          "bash-language-server",
          "json-lsp",
          "yaml-language-server",
          "taplo",
          -- Formatters
          "ruff",
          "gofumpt",
          "goimports",
          "stylua",
          "shfmt",
          -- Linters
          "shellcheck",
          -- DAP
          "debugpy",
          "delve",
        },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if cmp_ok then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
      end

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  -- ========== Completions ==========
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- ========== Formatting ==========
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
    },
    opts = {
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        go = { "goimports", "gofumpt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        json = { "jq" },
        yaml = { "prettier" },
        toml = { "taplo" },
      },
    },
  },

  -- ========== Linting ==========
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      }
      autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ========== Debugging ==========
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Debug: Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Debug: Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: Step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Debug: Conditional breakpoint" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        automatic_installation = true,
        handlers = {},
        ensure_installed = { "python", "delve" },
      })

      dapui.setup()
      require("dap-go").setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      -- Python debug adapter
      dap.adapters.python = {
        type = "executable",
        command = "debugpy-adapter",
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            return "python3"
          end,
        },
      }
    end,
  },

  -- ========== Git ==========
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local buf_map = function(mode, l, r, desc)
          map(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
        end

        buf_map("n", "]h", gs.next_hunk, "Next hunk")
        buf_map("n", "[h", gs.prev_hunk, "Previous hunk")
        buf_map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        buf_map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        buf_map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        buf_map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        buf_map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        buf_map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        buf_map("n", "<leader>gd", gs.diffthis, "Diff this")
      end,
    },
  },

  -- ========== Mini modules ==========
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })       -- Better text objects (around/inside)
      require("mini.surround").setup()                    -- Add/delete/replace surroundings
      require("mini.pairs").setup()                       -- Auto-close brackets
      require("mini.comment").setup()                     -- gcc / gc to comment
    end,
  },

}, {
  ui = {
    icons = vim.g.have_nerd_font ~= false and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤",
    },
  },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
