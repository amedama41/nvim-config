return {
    "amedama41/telescope-project-tabs.nvim",
    keys = { "<C-\\>p", "<C-\\>P" },
    dependencies = "nvim-telescope/telescope.nvim",
    opts = {
        root_dirs = {
            "~/.local/share/nvim/lazy",
            "~/repos",
            "~/work",
        },
        max_depth = 3,
    },
    config = function(_, opts)
        local project_tabs = require("telescope-project-tabs")

        project_tabs.setup(opts)

        local keymap_opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<C-\\>p", project_tabs.switch_project, keymap_opts)
        vim.keymap.set("n", "<C-\\>P", function()
            project_tabs.switch_project({ only_opened = true })
        end, keymap_opts)
    end,
}
