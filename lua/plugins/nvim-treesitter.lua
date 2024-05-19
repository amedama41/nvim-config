return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    main = "nvim-treesitter.configs",
    opts = {
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ic"] = "@class.inner",
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner",
                },
                selection_modes = {
                    ["@function.outer"] = "V",
                    ["@function.inner"] = "V",
                    ["@class.outer"] = "V",
                    ["@class.inner"] = "V",
                },
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    ["]k"] = "@class.outer",
                    ["]l"] = "@loop.outer",
                    ["]]"] = { query = { "@function.outer", "@class.outer" } },
                },
                goto_next_end = {
                    ["]K"] = "@class.outer",
                    ["]L"] = "@loop.outer",
                    ["]["] = { query = { "@function.outer", "@class.outer" } },
                },
                goto_previous_start = {
                    ["[k"] = "@class.outer",
                    ["[l"] = "@loop.outer",
                    ["[["] = { query = { "@function.outer", "@class.outer" } },
                },
                goto_previous_end = {
                    ["[K"] = "@class.outer",
                    ["[L"] = "@loop.outer",
                    ["[]"] = { query = { "@function.outer", "@class.outer" } },
                },
            },
        },
    },
}
