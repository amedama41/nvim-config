return {
    "github/copilot.vim",
    enabled = false,
    event = "InsertEnter",
    init = function()
        vim.g.copilot_filetypes = {
            gitcommit = true,
            markdown = true,
            vfiler = false,
        }
    end,
}
