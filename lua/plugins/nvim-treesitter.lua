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
                    ["ab"] = "@block.outer",
                    ["ib"] = "@block.inner",
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ai"] = "@conditional.outer",
                    ["ii"] = "@conditional.inner",
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner",
                    ["at"] = "@class.outer",
                    ["it"] = "@class.inner",
                },
                selection_modes = {
                    ["@block.outer"] = "V",
                    ["@block.inner"] = "V",
                    ["@function.outer"] = "V",
                    ["@function.inner"] = "V",
                    ["@conditional.outer"] = "V",
                    ["@conditional.inner"] = "V",
                    ["@loop.outer"] = "V",
                    ["@loop.inner"] = "V",
                    ["@class.outer"] = "V",
                    ["@class.inner"] = "V",
                },
            },
            move = {
                enable = true,
                disable = function(lang, bufnr)
                    local keymap_opts = { buffer = bufnr, noremap = true }
                    local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"
                    vim.keymap.set({ "n", "x", "o" }, "]]", ts_repeat_move.repeat_last_move_next, keymap_opts)
                    vim.keymap.set({ "n", "x", "o" }, "][", function()
                        ts_repeat_move.repeat_last_move({ forward = true, start = false })
                    end, keymap_opts)
                    vim.keymap.set({ "n", "x", "o" }, "[[", ts_repeat_move.repeat_last_move_previous, keymap_opts)
                    vim.keymap.set({ "n", "x", "o" }, "[]", function()
                        ts_repeat_move.repeat_last_move({ forward = false, start = false })
                    end, keymap_opts)
                    return false
                end,
                set_jumps = true,
                goto_next_start = {
                    ["]b"] = "@block.outer",
                    ["]f"] = "@function.outer",
                    ["]i"] = "@conditional.outer",
                    ["]l"] = "@loop.outer",
                    ["]t"] = "@class.outer",
                },
                goto_next_end = {
                    ["]B"] = "@block.outer",
                    ["]F"] = "@function.outer",
                    ["]I"] = "@conditional.outer",
                    ["]L"] = "@loop.outer",
                    ["]T"] = "@class.outer",
                },
                goto_previous_start = {
                    ["[b"] = "@block.outer",
                    ["[f"] = "@function.outer",
                    ["[t"] = "@class.outer",
                    ["[i"] = "@conditional.outer",
                    ["[l"] = "@loop.outer",
                },
                goto_previous_end = {
                    ["[B"] = "@block.outer",
                    ["[F"] = "@function.outer",
                    ["[I"] = "@conditional.outer",
                    ["[L"] = "@loop.outer",
                    ["[T"] = "@class.outer",
                },
            },
        },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
        local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
        parser_config.octo = {
            install_info = {
                url = "https://github.com/amedama41/tree-sitter-octo",
                files = { "src/parser.c", "src/scanner.c" },
                branch = "main",
                generate_requires_npm = false,
                requires_generate_from_grammar = false,
            },
            filetype = "octo",
        }
    end,
}
