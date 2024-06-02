return {
    "github/copilot.vim",
    enabled = require("env").enable_copilot,
    init = function()
        vim.g.copilot_filetypes = {
            gitcommit = true,
            markdown = true,
            vfiler = false,
        }
    end,
}
