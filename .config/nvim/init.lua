vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.updatetime = 250
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP References" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })

local function setup_brackets()
  local bracket_pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'", ["`"] = "`" }

  for open, close in pairs(bracket_pairs) do
    vim.keymap.set("i", open, function()
      return open .. close .. "<Left>"
    end, { expr = true, desc = "Auto-close " .. open .. close })
  end

  vim.keymap.set("i", "<BS>", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local char_before = line:sub(col, col)
    local char_after = line:sub(col + 1, col + 1)
    for open, close in pairs(bracket_pairs) do
      if char_before == open and char_after == close then
        return "<Del><BS>"
      end
    end
    return "<BS>"
  end, { expr = true, desc = "Delete bracket pair" })

  vim.keymap.set("i", "<CR>", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local char_before = line:sub(col, col)
    local char_after = line:sub(col + 1, col + 1)
    for open, close in pairs(bracket_pairs) do
      if char_before == open and char_after == close then
        return "<CR><CR><Esc>kA"
      end
    end
    return "<CR>"
  end, { expr = true, desc = "New line between brackets" })
end

setup_brackets()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "razcoen/fleet.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("fleet").setup({
        undercurl = true,
        underline = true,
        bold = true,
        italic = true,
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_indent_guides = false,
        inverse = true,
        contrast = "hard",
        palette_overrides = {},
        overrides = {
          Normal = { bg = "#000000" },
          CursorLine = { bg = "#0d0d0d" },
        },
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.cmd.colorscheme("fleet")
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "bashls",
        "clangd",
        "cssls",
        "gopls",
        "html",
        "jsonls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "ts_ls",
        "vimls",
        "yamlls",
      },
      automatic_enable = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = { generate = true, test = true, tidy = true },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " > ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "descending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = { "node_modules", ".git/", "target/" },
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
          },
          live_grep = {
            theme = "ivy",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
          },
        },
      })

      telescope.load_extension("fzf")

      local map = vim.keymap.set
      map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
      map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
      map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
      map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
      map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })
      map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document symbols" })
      map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git commits" })
      map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git status" })
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add" })
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon 1" })
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon 2" })
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })
      vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end, { desc = "Harpoon 5" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "go", "gomod", "lua", "vim", "vimdoc", "javascript", "typescript", "python", "rust", "json", "yaml", "bash", "c", "cpp" },
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
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
})