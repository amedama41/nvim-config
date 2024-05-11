return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/vim-vsnip",
    },
    opts = function()
        local cmp = require("cmp")
        local feedkeys = require("cmp.utils.feedkeys")
        local keymap = require("cmp.utils.keymap")
        return {
            -- REQUIRED - you must specify a snippet engine
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            preselect = cmp.PreselectMode.None,
            window = {
                -- completion = cmp.config.window.bordered(),
                -- documentation = cmp.config.window.bordered(),
            },
            mapping = {
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-l>"] = cmp.mapping.complete(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-c>"] = cmp.mapping.close(),
                ["<CR>"] = function(fallback)
                    -- https://github.com/hrsh7th/nvim-cmp/issues/1326
                    if vim.fn.pumvisible() == 1 then
                        if vim.fn.complete_info({ "selected" }).selected == -1 then
                            feedkeys.call(keymap.t("<CR>"), "in")
                        else
                            feedkeys.call(keymap.t("<C-X><C-Z>"), "in")
                        end
                    else
                        cmp.mapping.confirm({ select = false })(fallback)
                    end
                end,
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                -- { name = "buffer" },
            }, {
                { name = "buffer" },
            }),
        }
    end,
}
