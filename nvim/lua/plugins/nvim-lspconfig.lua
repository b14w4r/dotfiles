return {
  -- LSP Configuration
  -- https://github.com/neovim/nvim-lspconfig
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    -- LSP Management
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    require('mason').setup()
    require('mason-lspconfig').setup({
      -- Install these LSPs automatically
      ensure_installed = {
        'bashls',
        'cssls',
        'html',
        'gradle_ls',
        'groovyls',
        'lua_ls',
        'jdtls',          -- Java
        'kotlin_language_server', -- Kotlin (ДОБАВЛЕНО!)
        'jsonls',
        'lemminx',
        'marksman',
        'quick_lint_js',
        'yamlls',
        'pyright',
        'ruff',
      }
    })

    require('mason-tool-installer').setup({
      -- Install these linters, formatters, debuggers automatically
      ensure_installed = {
        'java-debug-adapter',
        'java-test',
        'ktlint',       -- Kotlin linter (ДОБАВЛЕНО!)
      },
    })

    -- Issue fix for mason-tools-installer with VeryLazy
    vim.api.nvim_command('MasonToolsInstall')

    local lspconfig = require('lspconfig')
    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    
    -- Настройка keybindings для LSP
    local lsp_attach = function(client, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      
      -- Базовые LSP биндинги
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Перейти к определению
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)          -- Перейти к объявлению
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)       -- Перейти к реализации
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)           -- Показать ссылки
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                 -- Показать документацию
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)       -- Переименовать
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)  -- Code actions
      vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)        -- Форматирование
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)         -- Предыдущая ошибка
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)         -- Следующая ошибка
    end

    -- Python LSP (pyright + ruff)
    lspconfig.pyright.setup({
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
      filetypes = {"python"},
    })

    lspconfig.ruff.setup({
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
      init_options = {
        settings = {
          organizeImports = true,
          fixAll = true,
        }
      }
    })

    -- Kotlin LSP setup
    lspconfig.kotlin_language_server.setup({
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
      root_dir = lspconfig.util.root_pattern("settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts", ".git"),
      settings = {
        kotlin = {
          compiler = {
            jvm = {
              target = "21"  -- Или твоя версия JVM
            }
          }
        }
      }
    })

    -- Setup all other LSP servers (кроме jdtls - он настраивается через ftplugin)
    require('mason-lspconfig').setup_handlers({
      function(server_name)
        -- Пропускаем jdtls и kotlin_language_server (настроили выше)
        if server_name ~= 'jdtls' and server_name ~= 'kotlin_language_server' then
          lspconfig[server_name].setup({
            on_attach = lsp_attach,
            capabilities = lsp_capabilities,
          })
        end
      end
    })

    -- Lua LSP settings (для конфигов nvim)
    lspconfig.lua_ls.setup {
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
        },
      },
    }

    -- Настройка отображения диагностики
    vim.diagnostic.config({
      virtual_text = true,         -- Показывать ошибки прямо в коде
      signs = true,                 -- Показывать иконки в колонке слева
      underline = true,            -- Подчеркивать ошибки
      update_in_insert = false,    -- Не обновлять в insert mode
      severity_sort = true,        -- Сортировать по важности
      float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
      },
    })

    -- Иконки для диагностики
    local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    -- Скругленные границы для всех LSP floating windows
    local open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded"
      return open_floating_preview(contents, syntax, opts, ...)
    end
  end
}

