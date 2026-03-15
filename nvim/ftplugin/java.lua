-- JDTLS (Java LSP) configuration
local home = vim.env.HOME
local jdtls = require("jdtls")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = home .. "/jdtls-workspace/" .. project_name

-- Determine OS
local system_os = ""
if vim.fn.has("mac") == 1 then
  system_os = "mac"
elseif vim.fn.has("unix") == 1 then
  system_os = "linux"
elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  system_os = "win"
else
  print("OS not found, defaulting to 'linux'")
  system_os = "linux"
end

-- ВАЖНО: Проверь эти пути на своей системе!
local mason_path = home .. "/.local/share/nvim/mason"
local jdtls_path = mason_path .. "/packages/jdtls"

-- Debug & Test bundles
local bundles = {
  vim.fn.glob(mason_path .. "/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar"),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "/share/java-test/*.jar", true), "\n"))

-- JDTLS configuration
local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-javaagent:" .. mason_path .. "/share/jdtls/lombok.jar",
    "-Xmx4g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    jdtls_path .. "/config_" .. system_os,
    "-data",
    workspace_dir,
  },

  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" }),

  settings = {
    java = {
      home = "/usr/lib/jvm/java-21-openjdk",  -- ПРОВЕРЬ ЭТОТ ПУТЬ!
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-21",
            path = "/usr/lib/jvm/java-21-openjdk",  -- И ЭТОТ!
          },
          -- Если используешь другие версии Java, добавь их:
          -- {
          --   name = "JavaSE-17",
          --   path = "/usr/lib/jvm/java-17-openjdk",
          -- },
        },
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      signatureHelp = { enabled = true },
      format = {
        enabled = true,
        settings = {
          -- Можешь указать свой style guide:
          -- url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
          -- profile = "GoogleStyle",
        },
      },
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
        importOrder = {
          "java",
          "javax",
          "jakarta",
          "com",
          "org"
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
    },
  },

  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  
  flags = {
    allow_incremental_sync = true,
  },
  
  init_options = {
    bundles = bundles,
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
  },
}

-- Keybindings специфичные для Java
config["on_attach"] = function(client, bufnr)
  -- Setup debugging
  jdtls.setup_dap({ hotcodereplace = "auto" })
  require("jdtls.dap").setup_dap_main_class_configs()

  local opts = { buffer = bufnr, noremap = true, silent = true }
  
  -- Java-specific keymaps
  vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, opts)        -- Organize imports
  vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, opts)        -- Extract variable
  vim.keymap.set('v', '<leader>jv', [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]], opts)
  vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, opts)        -- Extract constant
  vim.keymap.set('v', '<leader>jc', [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]], opts)
  vim.keymap.set('v', '<leader>jm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)  -- Extract method
  vim.keymap.set('n', '<leader>ju', jdtls.update_projects_config, opts)  -- Update project config
  vim.keymap.set('n', '<leader>jtc', jdtls.test_class, opts)             -- Test class
  vim.keymap.set('n', '<leader>jtm', jdtls.test_nearest_method, opts)    -- Test method
end

-- Start or attach to JDTLS
jdtls.start_or_attach(config)

-- Автоформатирование при сохранении (опционально)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.java",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

