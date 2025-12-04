-- Modern, Feature-Rich Go Development Environment for Neovim
-- This configuration provides a comprehensive Go development setup with:
-- • Advanced Go tooling via go.nvim
-- • Full debugging support with DAP
-- • Comprehensive LSP integration  
-- • Testing and benchmarking
-- • Code generation and refactoring
-- • Modern UI and productivity features

return {
  -- Ray-x go.nvim - The most comprehensive Go plugin for Neovim
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua", -- Optional: provides floating window support
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        -- Disable LSP config since LazyVim handles it
        lsp_cfg = false,
        
        -- Linter and formatter settings
        lsp_gofumpt = true, -- Use gofumpt for better formatting
        goimports = "gopls", -- Use gopls for imports
        gofmt = "gofumpt", -- Use gofumpt instead of gofmt
        
        -- Advanced features
        max_line_len = 120,
        tag_transform = "camelcase", -- Transform struct tags
        tag_options = "json=omitempty",
        gotests_flags = { "-exported", "-all" }, -- Generate tests for all functions
        comment_placeholder = " ", -- Placeholder for generated comments
        
        -- Icons and UI
        icons = { breakpoint = "🔴", currentpos = "👉" },
        verbose = false, -- Set to true for debugging
        
        -- Debugging
        dap_debug = true,
        dap_debug_keymap = true, -- Auto setup debug keymaps
        dap_debug_gui = { layouts = { "stack", "breakpoint" } },
        dap_debug_vt = { enabled_commands = true, all_frames = true },
        
        -- Testing
        test_runner = "go", -- Use go test
        run_in_floaterm = false, -- Run in terminal buffer instead
        floaterm = { posititon = "bottom", width = 0.45, height = 0.98 },
        
        -- Trouble integration for better error handling
        trouble = true,
        luasnip = true, -- Enable luasnip integration
      })
      
      -- Auto format on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require('go.format').goimports()
        end,
        group = format_sync_grp,
      })
    end,
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()', -- Update all Go tools
  },

  -- Enhanced DAP setup for Go debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      
      -- Setup DAP UI
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })
      
      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      
      -- Enhanced debugging keymaps
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<leader>da", function()
        dap.continue({ before = get_args })
      end, { desc = "Run with Args" })
      vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to Cursor" })
      vim.keymap.set("n", "<leader>dg", dap.goto_, { desc = "Go to line (no execute)" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Down" })
      vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Up" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dO", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>dp", dap.pause, { desc = "Pause" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
      vim.keymap.set("n", "<leader>ds", dap.session, { desc = "Session" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
      vim.keymap.set("n", "<leader>dw", function()
        require("dap.ui.widgets").hover()
      end, { desc = "Widgets" })
    end,
  },

  -- Go-specific DAP configuration
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
          {
            type = "go",
            name = "Debug (Build Flags & Arguments)",
            request = "launch",
            program = "${file}",
            args = require("dap-go").get_arguments,
            buildFlags = require("dap-go").get_build_flags,
          },
        },
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
          detached = vim.fn.has("win32") == 0,
        },
        tests = {
          verbose = false,
        },
      })
      
      -- Go-specific debugging keymaps
      vim.keymap.set("n", "<leader>gdt", function()
        require("dap-go").debug_test()
      end, { desc = "Debug Test" })
      vim.keymap.set("n", "<leader>gdl", function()
        require("dap-go").debug_last_test()
      end, { desc = "Debug Last Test" })
    end,
    ft = "go",
  },

  -- Virtual text for debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == "inline" then
            return " = " .. variable.value
          else
            return variable.name .. " = " .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
      })
    end,
  },

  -- Enhanced testing with neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-go")({
            experimental = {
              test_table = true,
            },
            args = { "-count=1", "-timeout=60s" },
          }),
        },
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            if require("lazyvim.util").has("trouble.nvim") then
              vim.cmd("Trouble quickfix")
            else
              vim.cmd("copen")
            end
          end,
        },
      })
      
      -- Testing keymaps
      vim.keymap.set("n", "<leader>tt", function()
        require("neotest").run.run(vim.fn.expand("%"))
      end, { desc = "Run File" })
      vim.keymap.set("n", "<leader>tT", function()
        require("neotest").run.run(vim.uv.cwd())
      end, { desc = "Run All Test Files" })
      vim.keymap.set("n", "<leader>tr", function()
        require("neotest").run.run()
      end, { desc = "Run Nearest" })
      vim.keymap.set("n", "<leader>tl", function()
        require("neotest").run.run_last()
      end, { desc = "Run Last" })
      vim.keymap.set("n", "<leader>ts", function()
        require("neotest").summary.toggle()
      end, { desc = "Toggle Summary" })
      vim.keymap.set("n", "<leader>to", function()
        require("neotest").output.open({ enter = true, auto_close = true })
      end, { desc = "Show Output" })
      vim.keymap.set("n", "<leader>tO", function()
        require("neotest").output_panel.toggle()
      end, { desc = "Toggle Output Panel" })
      vim.keymap.set("n", "<leader>tS", function()
        require("neotest").run.stop()
      end, { desc = "Stop" })
    end,
  },

  -- Enhanced Mason setup for Go tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Go language server and tools
        "gopls",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "gotests",
        "impl",
        
        -- Linters and formatters
        "golangci-lint",
        "staticcheck",
        "revive",
        
        -- Debugging
        "delve",
        
        -- Additional tools
        "templ", -- For Go templates
      },
    },
  },

  -- Enhanced Treesitter for Go
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "go",
        "gomod",
        "gowork",
        "gosum",
        "gotmpl",
        "proto", -- Protocol buffers
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
    },
  },

  -- Advanced code intelligence with symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup({
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        width = 25,
        auto_close = false,
        show_numbers = false,
        show_relative_numbers = false,
        show_symbol_details = true,
        preview_bg_highlight = "Pmenu",
        autofold_depth = nil,
        auto_unfold_hover = true,
        fold_markers = { "", "" },
        wrap = false,
        keymaps = {
          close = { "<Esc>", "q" },
          goto_location = "<Cr>",
          focus_location = "o",
          hover_symbol = "<C-space>",
          toggle_preview = "K",
          rename_symbol = "r",
          code_actions = "a",
          fold = "h",
          unfold = "l",
          fold_all = "W",
          unfold_all = "E",
          fold_reset = "R",
        },
        lsp_blacklist = {},
        symbol_blacklist = {},
        symbols = {
          File = { icon = "", hl = "@text.uri" },
          Module = { icon = "", hl = "@namespace" },
          Namespace = { icon = "", hl = "@namespace" },
          Package = { icon = "", hl = "@namespace" },
          Class = { icon = "𝓒", hl = "@type" },
          Method = { icon = "ƒ", hl = "@method" },
          Property = { icon = "", hl = "@method" },
          Field = { icon = "", hl = "@field" },
          Constructor = { icon = "", hl = "@constructor" },
          Enum = { icon = "ℰ", hl = "@type" },
          Interface = { icon = "ﰮ", hl = "@type" },
          Function = { icon = "", hl = "@function" },
          Variable = { icon = "", hl = "@constant" },
          Constant = { icon = "", hl = "@constant" },
          String = { icon = "𝓐", hl = "@string" },
          Number = { icon = "#", hl = "@number" },
          Boolean = { icon = "⊨", hl = "@boolean" },
          Array = { icon = "", hl = "@constant" },
          Object = { icon = "⦿", hl = "@type" },
          Key = { icon = "🔐", hl = "@type" },
          Null = { icon = "NULL", hl = "@type" },
          EnumMember = { icon = "", hl = "@field" },
          Struct = { icon = "𝓢", hl = "@type" },
          Event = { icon = "🗲", hl = "@type" },
          Operator = { icon = "+", hl = "@operator" },
          TypeParameter = { icon = "𝙏", hl = "@parameter" },
        },
      })
      
      vim.keymap.set("n", "<leader>cs", "<cmd>SymbolsOutline<cr>", { desc = "Symbols Outline" })
    end,
    ft = "go",
  },

  -- Enhanced snippets for Go
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      
      ls.add_snippets("go", {
        s("errf", {
          t("if err != nil {"), t({"", "\t"}),
          t("return "), i(1, "err"), t({"", "}"})
        }),
        s("errp", {
          t("if err != nil {"), t({"", "\t"}),
          t("panic(err)"), t({"", "}"})
        }),
        s("errl", {
          t("if err != nil {"), t({"", "\t"}),
          t("log.Fatal(err)"), t({"", "}"})
        }),
        s("main", {
          t({"package main", "", "import (", "\t\"fmt\"", ")", "", "func main() {", "\t"}),
          i(1), t({"", "}"})
        }),
        s("iferr", {
          t("if err != nil {"), t({"", "\t"}),
          i(1, "// handle error"), t({"", "}"})
        }),
        s("test", {
          t("func Test"), i(1, "Name"), t("(t *testing.T) {"), t({"", "\t"}),
          i(2, "// test code"), t({"", "}"})
        }),
        s("bench", {
          t("func Benchmark"), i(1, "Name"), t("(b *testing.B) {"), t({"", "\t"}),
          t("for i := 0; i < b.N; i++ {"), t({"", "\t\t"}),
          i(2, "// benchmark code"), t({"", "\t}"}), t({"", "}"})
        }),
      })
    end,
  },

  -- Additional key mappings for Go development
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>g", group = "Go" },
        { "<leader>gd", group = "Debug" },
        { "<leader>gt", group = "Test" },
        { "<leader>gr", group = "Refactor" },
      },
    },
  },
}
