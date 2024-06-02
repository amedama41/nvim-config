return {
    "hrsh7th/vim-vsnip",
    event = "InsertEnter",
    config = function()
        vim.keymap.set({ "i", "s" }, "<C-i>", function()
            if vim.fn["vsnip#jumpable"](1) == 1 then
                return "<Plug>(vsnip-jump-next)"
            else
                return "<C-i>"
            end
        end, { expr = true })
        vim.keymap.set({ "i", "s" }, "<S-C-i>", function()
            if vim.fn["vsnip#jumpable"](-1) == 1 then
                return "<Plug>(vsnip-jump-prev)"
            else
                return "<S-C-i>"
            end
        end, { expr = true })
    end,
}
