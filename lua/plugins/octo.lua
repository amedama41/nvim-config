return {
    -- "pwntester/octo.nvim",
    "amedama41/octo.nvim",
    branch = "septem",
    cmd = { "Octo" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        use_local_fs = true,
        picker_config = {
            mappings = {
                open_in_browse = { lhs = "<C-g>K", desc = "open issue in browser" },
                copy_url = { lhs = "<C-g>Y", desc = "copy url to system clipboard" },
                checkout_pr = { lhs = "<C-g>C", desc = "checkout pull request" },
                merge_pr = { lhs = "<C-g>M", desc = "merge pull request" },
            },
        },
        issues = {
            order_by = {
                field = "UPDATED_AT",
                direction = "DESC",
            },
        },
        pull_requests = {
            order_by = {
                field = "UPDATED_AT",
                direction = "DESC",
            },
        },
        mappings = {
            issue = {
                reload = { lhs = "g<C-l>", desc = "reload issue" },
                open_in_browser = { lhs = "gK", desc = "open issue in browser" },
                copy_url = { lhs = "gY", desc = "copy url to system clipboard" },
            },
            pull_request = {
                reload = { lhs = "g<C-l>", desc = "reload PR" },
                open_in_browser = { lhs = "gK", desc = "open PR in browser" },
                copy_url = { lhs = "gY", desc = "copy url to system clipboard" },
            },
            review_thread = {
                select_next_entry = { lhs = "<Tab>", desc = "move to previous changed file" },
                select_prev_entry = { lhs = "<S-Tab>", desc = "move to next changed file" },
            },
            review_diff = {
                select_next_entry = { lhs = "<Tab>", desc = "move to previous changed file" },
                select_prev_entry = { lhs = "<S-Tab>", desc = "move to next changed file" },
            },
            file_panel = {
                refresh_files = { lhs = "<C-l>", desc = "refresh changed files panel" },
                select_next_entry = { lhs = "<Tab>", desc = "move to previous changed file" },
                select_prev_entry = { lhs = "<S-Tab>", desc = "move to next changed file" },
            },
        },
    },
    init = function()
        vim.treesitter.language.register("markdown", "octo")
    end,
}
