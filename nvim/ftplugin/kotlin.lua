-- Kotlin-specific settings
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
vim.opt_local.softtabstop = 4

-- Дополнительные настройки для Kotlin
vim.opt_local.colorcolumn = "120"  -- Линия на 120 символов
vim.opt_local.textwidth = 120

-- LSP уже настроен в nvim-lspconfig.lua, здесь можно добавить
-- специфичные для файла keybindings если нужно

-- Автоформатирование при сохранении (опционально)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.kt",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

