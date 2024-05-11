return {
    "hrsh7th/vim-vsnip",
    event = "InsertEnter",
    config = function()
        vim.keymap.set({ "i", "s" }, "<Tab>", function()
            if vim.fn["vsnip#jumpable"](1) == 1 then
                return "<Plug>(vsnip-jump-next)"
            else
                return "<tab>"
            end
        end, { expr = true })
        vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
            if vim.fn["vsnip#jumpable"](-1) == 1 then
                return "<Plug>(vsnip-jump-prev)"
            else
                return "<tab>"
            end
        end, { expr = true })
    end,
}
