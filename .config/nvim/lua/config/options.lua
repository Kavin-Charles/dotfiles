local o = vim.opt
o.termguicolors = true
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.wrap = false
o.scrolloff = 8
o.sidescrolloff = 8
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.clipboard = "unnamedplus"
o.mouse = "a"
o.undofile = true
o.swapfile = false
o.updatetime = 200
o.timeoutlen = 400
o.completeopt = { "menu", "menuone", "noselect" }
o.pumheight = 10
o.laststatus = 3
o.showmode = false
o.winborder = "rounded"
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.fillchars = { eob = " ", fold = " " }
o.grepprg = "rg --vimgrep --smart-case"
o.grepformat = "%f:%l:%c:%m"
vim.diagnostic.config({
  virtual_text = false, severity_sort = true, underline = true, update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = { text = { [1] = "●", [2] = "●", [3] = "●", [4] = "●" } },
})
local group = vim.api.nvim_create_augroup("ObsidianEditing", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group, callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "lua", "javascript", "typescript", "javascriptreact", "typescriptreact", "html", "css", "json", "yaml", "sh" },
  callback = function() vim.bo.shiftwidth = 2; vim.bo.softtabstop = 2 end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = group, pattern = { "markdown", "text", "gitcommit" },
  callback = function() vim.wo.wrap = true; vim.wo.linebreak = true end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    local pos = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if pos[1] > 1 and pos[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end
  end,
})
