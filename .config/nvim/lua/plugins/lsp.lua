return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "bashls",
        "clangd",
        "cssls",
        "html",
        "lua_ls",
        "vimls",
        "sqlls",
      },
    },
  },
  {
    "mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
  },
}
