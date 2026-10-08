-- Obsidian Purple: small modules, deferred tools, no startup downloads.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH
require("config.options")
require("config.keymaps")
vim.cmd.colorscheme("obsidian-purple")
local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy) then
  vim.notify("lazy.nvim is missing. See ~/.config/nvim/README.md", vim.log.levels.ERROR)
  return
end
vim.opt.rtp:prepend(lazy)
require("lazy").setup("plugins", {
  defaults = { lazy = true },
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "zipPlugin", "tutor" } } },
})
