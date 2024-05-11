return {
    "amedama41/scallop.nvim",
    ft = { "scallopedit", "*.scallopedit" },
    cmd = { "Scallop", "ScallopEdit" },
    keys = { "<C-k>", "g<C-k>" },
    dependencies = {
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "amarakon/nvim-cmp-buffer-lines",
        "hrsh7th/cmp-path",
    },
    config = function()
        local env = require("env")
        require("scallop.configs").setup({
            options = {
                prompt_pattern = env.prompt_pattern,
                history_filepath = "~/.bash_history",
                history_filter = function(data)
                    if data:find("[:graph:]%s+[:graph:]") == nil then
                        return false
                    end
                    if data:find("^ghp_") ~= nil then
                        return false
                    end
                    return true
                end,
                floating_border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
                edit_filetype = "bash.scallopedit",
                edit_win_options = {
                    wrap = true,
                    number = true,
                    conceallevel = 2,
                    concealcursor = "nvic",
                    foldmethod = "marker",
                },
            },
        })
        vim.keymap.set("n", "<C-k>", function()
            require("scallop").start_terminal_edit()
        end, { noremap = true, silent = true })
        vim.keymap.set("n", "g<C-k>", function()
            require("scallop").start_terminal()
        end, { noremap = true, silent = true })

        local cmp = require("cmp")
        local compare = require("cmp.config.compare")
        local pattern = vim.regex([[\S\s\+\S]])
        local history_filter = function(entry, _)
            local text = entry:get_insert_text()
            if pattern:match_str(text) == nil then
                return false
            end
            if vim.startswith(text, "ghp_") then
                return false
            end
            return true
        end
        cmp.setup.filetype({ "bash.scallopedit" }, {
            formatting = {
                format = function(entry, vim_item)
                    if entry.source.name == "scallop_shell_history" then
                        vim_item.kind = "History"
                    elseif entry.source.name == "buffer-lines" then
                        vim_item.kind = "Scallop"
                    end
                    if #vim_item.word > 80 then
                        vim_item.abbr = vim_item.word:sub(1, 80) .. "..."
                    end
                    return vim_item
                end,
            },
            matching = {
                disallow_fuzzy_matching = true,
                disallow_fullfuzzy_matching = true,
                disallow_partial_fuzzy_matching = true,
                disallow_partial_matching = false,
                disallow_prefix_unmatching = true,
                disallow_symbol_nonprefix_matching = false,
            },
            sorting = {
                comparators = {
                    function(entry1, entry2)
                        local source_rank = {
                            ["path"] = 0,
                            ["buffer-lines"] = 1,
                            ["scallop_shell_history"] = 2,
                            ["nvim_lsp"] = 3,
                        }
                        local source_rank1 = source_rank[entry1.source.name]
                        local source_rank2 = source_rank[entry2.source.name]
                        if source_rank1 == source_rank2 then
                            return nil
                        end
                        return source_rank1 < source_rank2
                    end,
                    function(entry1, entry2)
                        if entry1.source.name == "scallop_shell_history" then
                            return entry1.id < entry2.id
                        end
                        if entry1.source.name == "buffer-line" then
                            return entry2.id < entry1.id
                        end
                        return nil
                    end,
                    compare.offset,
                    compare.exact,
                    -- compare.scopes,
                    compare.score,
                    compare.recently_used,
                    compare.locality,
                    compare.kind,
                    -- compare.sort_text,
                    compare.length,
                    compare.order,
                },
            },
            sources = {
                { name = "nvim_lsp" },
                { name = "scallop_shell_history", entry_filter = history_filter, max_item_count = 50 },
                { name = "buffer-lines", entry_filter = history_filter },
                {
                    name = "path",
                    option = {
                        get_cwd = function()
                            return vim.fn.getcwd()
                        end,
                    },
                },
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "bash.scallopedit" },
            callback = function()
                vim.lsp.start({
                    name = "bashls_mod",
                    -- cmd = { "/Users/Macbook/repos/bash-language-server/server/out/cli.js", "start" },
                    cmd = { "bash-language-server-mod", "start" },
                    root_dir = nil,
                })
            end,
        })
    end,
}
