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

vim.opt.cursorline = true
vim.cmd("hi CursorLine guibg=#0d0d0d")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false

    vim.cmd([[
      hi goFunction guifg=#61afef gui=bold
      hi goMethod guifg=#61afef gui=italic
      hi goStruct guifg=#e5c07b
      hi goStructDef guifg=#e5c07b gui=bold
      hi goType guifg=#c678dd
      hi goPackage guifg=#c678dd gui=bold
      hi goImport guifg=#98c379
      hi goString guifg=#98c379
      hi goRawString guifg=#98c379 gui=italic
      hi goNumber guifg=#d19a66
      hi goFloat guifg=#d19a66
      hi goDecimalInt guifg=#d19a66
      hi goHexadecimalInt guifg=#d19a66
      hi goOctalInt guifg=#d19a66
      hi goBoolean guifg=#d19a66 gui=bold
      hi goConstant guifg=#d19a66 gui=bold
      hi goKeyword guifg=#c678dd gui=bold
      hi goStatement guifg=#c678dd gui=bold
      hi goConditional guifg=#c678dd gui=bold
      hi goRepeat guifg=#c678dd gui=bold
      hi goLabel guifg=#c678dd gui=bold
      hi goDecorator guifg=#e06c75
      hi goFunctionCall guifg=#61afef
      hi goMethodCall guifg=#61afef
      hi goField guifg=#e06c75
      hi goArgumentName guifg=#e06c75
      hi goReturnName guifg=#e06c75
      hi goTypeDeclaration guifg=#c678dd gui=bold
      hi goBuiltins guifg=#e06c75 gui=bold
      hi goTodo guifg=#e5c07b gui=bold
      hi goComment guifg=#5c6370 gui=italic
      hi goDocComment guifg=#5c6370 gui=italic
      hi goFormatStrings guifg=#98c379
      hi goEscapeOctal guifg=#d19a66
      hi goEscapeC guifg=#d19a66
      hi goEscapeX guifg=#d19a66
      hi goEscapeU guifg=#d19a66
      hi goEscapeBigU guifg=#d19a66
    ]])
  end,
})