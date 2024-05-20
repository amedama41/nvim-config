return {
    "amedama41/scallop.nvim",
    ft = { "scallopedit", "*.scallopedit" },
    cmd = { "Scallop", "ScallopEdit" },
    keys = { "<C-k>", "g<C-k>" },
    dependencies = {
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
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
            require("scallop").open_edit(nil, vim.fn.getcwd())
        end, { noremap = true, silent = true })
        vim.keymap.set("n", "g<C-k>", function()
            require("scallop").open_terminal()
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
                            ["scallop_shell_history"] = 1,
                            ["nvim_lsp"] = 2,
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

        local augroup = vim.api.nvim_create_augroup("vimrc-scallop-settings", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            pattern = { "scallop" },
            callback = function()
                vim.keymap.set("n", "a", function()
                    require("scallop").open_edit()
                end, { buffer = true })
                vim.keymap.set("n", "i", function()
                    require("scallop").open_edit()
                end, { buffer = true })
                vim.keymap.set("n", "<C-c>", function()
                    require("scallop").close_terminal()
                end, { buffer = true })
                vim.keymap.set({ "n", "x" }, "<C-n>", function()
                    require("scallop").jump_to_prompt("forward")
                end, { buffer = true })
                vim.keymap.set({ "n", "x" }, "<C-p>", function()
                    require("scallop").jump_to_prompt("backward")
                end, { buffer = true })
                vim.keymap.set("n", "<C-y>", function()
                    require("scallop").yank_from_prompt(true)
                end, { buffer = true })
                vim.keymap.set("n", "<C-^>", function()
                    require("scallop").switch_terminal()
                end, { buffer = true })
            end,
        })
        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            pattern = { "bash.scallopedit" },
            callback = function()
                vim.lsp.start({
                    name = "bashls_mod",
                    -- cmd = { "/Users/Macbook/repos/bash-language-server/server/out/cli.js", "start" },
                    cmd = { "bash-language-server-mod", "start" },
                    root_dir = nil,
                })

                -- This mapping is needed for <C-g><C-c> mapping
                vim.keymap.set("n", "<C-c>", function()
                    require("scallop").close_edit()
                end, { buffer = true })
                vim.keymap.set("i", "<C-c>", function()
                    require("scallop").close_terminal()
                end, { buffer = true })
                vim.keymap.set({ "n" }, "<C-^>", function()
                    require("scallop").switch_terminal()
                end, { buffer = true })
                vim.keymap.set({ "n", "i" }, "<C-g><C-g>", function()
                    require("scallop").scroll_to_bottom()
                end, { buffer = true })
                vim.keymap.set({ "n", "i" }, "<C-g><C-n>", function()
                    require("scallop").jump_to_prompt("forward")
                end, { buffer = true })
                vim.keymap.set({ "n", "i" }, "<C-g><C-p>", function()
                    require("scallop").jump_to_prompt("backward")
                end, { buffer = true })
                vim.keymap.set({ "n", "i" }, "<C-g><C-y>", function()
                    require("scallop").yank_from_prompt(false)
                end, { buffer = true })
                vim.keymap.set({ "n", "i" }, "<C-g><C-^>", function()
                    require("scallop").switch_terminal()
                end, { buffer = true })
                vim.keymap.set({ "n", "i" }, "<C-g>", function()
                    local ok, char = pcall(vim.fn.getcharstr, 0)
                    if not ok then
                        vim.print(":" .. char .. ":")
                        return
                    end
                    require("scallop").send_to_terminal(char)
                end, { buffer = true })
                vim.keymap.set("i", "<C-x><C-o>", function()
                    cmp.complete({
                        config = {
                            sources = {
                                { name = "nvim_lsp" },
                            },
                        },
                    })
                end, { buffer = true })
            end,
        })
    end,
}
