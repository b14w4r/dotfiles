return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.codespell,
        null_ls.builtins.diagnostics.mypy,}
        -- null_ls.builtins.diagnostics.ruff,}
        -- null_ls.builtins.code_actions.codespell, 
    })
  end
}
