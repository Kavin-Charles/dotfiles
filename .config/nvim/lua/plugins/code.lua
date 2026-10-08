return {
  { "mason-org/mason.nvim", cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog", "MasonUninstall" }, opts = { ui = { border = "rounded" } } },
  {
    "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function() require("config.lsp") end,
  },
  {
    "hrsh7th/nvim-cmp", event = "InsertEnter",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" },
    config = function() require("config.completion") end,
  },
  {
    "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false,
    config = function()
      require("nvim-treesitter").setup({})
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("ObsidianTreesitter", { clear = true }),
        callback = function(ev)
          if vim.bo[ev.buf].buftype ~= "" or vim.api.nvim_buf_line_count(ev.buf) > 20000 then return end
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim", event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "_" }, topdelete = { text = "‾" }, changedelete = { text = "~" } },
      current_line_blame = false,
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(key, fn, desc) vim.keymap.set("n", key, fn, { buffer = buf, desc = desc }) end
        map("]h", function() gs.nav_hunk("next") end, "Next Git hunk")
        map("[h", function() gs.nav_hunk("prev") end, "Previous Git hunk")
        map("<leader>gp", gs.preview_hunk, "Preview hunk")
        map("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("<leader>gS", gs.stage_hunk, "Stage hunk")
        map("<leader>gd", gs.diffthis, "Diff file")
      end,
    },
  },
  {
    "stevearc/conform.nvim", cmd = "ConformInfo",
    keys = { { "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, mode = { "n", "v" }, desc = "Format code" } },
    opts = { formatters_by_ft = {
      lua = { "stylua" }, python = { "ruff_format" }, javascript = { "prettier" },
      typescript = { "prettier" }, javascriptreact = { "prettier" }, typescriptreact = { "prettier" },
      json = { "prettier" }, yaml = { "prettier" }, html = { "prettier" }, css = { "prettier" },
      markdown = { "prettier" }, sh = { "shfmt" }, go = { "gofmt" }, rust = { "rustfmt" },
    } },
  },
}
