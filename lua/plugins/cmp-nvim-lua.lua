return {
    "hrsh7th/cmp-nvim-lua",
    ft = "lua",
    dependencies = {
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local cmp = require("cmp")
        cmp.setup.filetype({ "lua" }, {
            sources = {
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "nvim_lua" },
            },
        })
    end,
}
