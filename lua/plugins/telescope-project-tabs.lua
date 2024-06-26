return {
    "amedama41/telescope-project-tabs.nvim",
    keys = { "<C-\\>p", "<C-\\>P" },
    dependencies = "nvim-telescope/telescope.nvim",
    opts = require("env").project_tabs_config,
    config = function(_, opts)
        local project_tabs = require("telescope-project-tabs")

        project_tabs.setup(opts)

        local keymap_opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<C-\\>p", project_tabs.switch_project, keymap_opts)
        vim.keymap.set("n", "<C-\\><C-p>", function()
            project_tabs.switch_project({ only_opened = true, initial_mode = "normal" })
        end, keymap_opts)
    end,
}
