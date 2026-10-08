vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } } },
})
vim.lsp.config("gopls", { settings = { gopls = { gofumpt = true, staticcheck = true, completeUnimported = true } } })
local servers = {
  bashls = "bash-language-server", clangd = "clangd", cssls = "vscode-css-language-server",
  gopls = "gopls", html = "vscode-html-language-server", jsonls = "vscode-json-language-server",
  lua_ls = "lua-language-server", pyright = "pyright-langserver", rust_analyzer = "rust-analyzer",
  ts_ls = "typescript-language-server", vimls = "vim-language-server", yamlls = "yaml-language-server",
}
-- Mason exposes servers already installed. No network work on startup.
for server, command in pairs(servers) do
  if vim.fn.executable(command) == 1 then vim.lsp.enable(server) end
end
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ObsidianLsp", { clear = true }),
  callback = function(ev)
    local function map(key, fn, desc) vim.keymap.set("n", key, fn, { buffer = ev.buf, desc = desc }) end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gr", vim.lsp.buf.references, "References")
    map("gi", vim.lsp.buf.implementation, "Implementation")
    map("K", vim.lsp.buf.hover, "Documentation")
    map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>cs", vim.lsp.buf.signature_help, "Signature help")
  end,
})
