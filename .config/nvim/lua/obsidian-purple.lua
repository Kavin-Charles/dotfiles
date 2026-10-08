local c = { bg="#09070d", surface="#17101f", border="#382447", fg="#eee6f7", muted="#806b96", accent="#b58cff", pale="#cbb1ff" }
local function apply()
  for _,g in ipairs({"Normal", "NormalNC", "SignColumn", "EndOfBuffer"}) do vim.api.nvim_set_hl(0,g,{fg=c.fg,bg="NONE"}) end
  vim.api.nvim_set_hl(0,"NormalFloat",{fg=c.fg,bg=c.surface})
  vim.api.nvim_set_hl(0,"FloatBorder",{fg=c.accent,bg=c.surface})
  vim.api.nvim_set_hl(0,"Visual",{bg=c.border})
  vim.api.nvim_set_hl(0,"CursorLine",{bg=c.surface})
  vim.api.nvim_set_hl(0,"LineNr",{fg=c.muted})
  vim.api.nvim_set_hl(0,"CursorLineNr",{fg=c.accent,bold=true})
  vim.api.nvim_set_hl(0,"StatusLine",{fg=c.pale,bg=c.surface})
  for _,g in ipairs({"Keyword", "Statement", "Type", "@keyword", "@type"}) do vim.api.nvim_set_hl(0,g,{fg=c.accent}) end
  vim.api.nvim_set_hl(0,"Function",{fg=c.pale})
  vim.api.nvim_set_hl(0,"Comment",{fg=c.muted,italic=true})
end
vim.api.nvim_create_autocmd("ColorScheme",{group=vim.api.nvim_create_augroup("ObsidianPurple",{clear=true}),callback=apply})
apply()
