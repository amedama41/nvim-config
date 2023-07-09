local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({
            "git", "clone", "--depth", "1",
            "https://github.com/wbthomason/packer.nvim",
            install_path
        })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
    use "wbthomason/packer.nvim"

    use "neovim/nvim-lspconfig"
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/vim-vsnip"
    use { "jose-elias-alvarez/null-ls.nvim", requires = "nvim-lua/plenary.nvim" }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
        vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
        vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
        vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
        vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    end
})

require("mason").setup()
require("mason-lspconfig").setup_handlers({ function(server)
    local lspconfig = require("lspconfig")
    if server ~= "pyright" then
        lspconfig[server].setup {
            capabilities = require("cmp_nvim_lsp").default_capabilities()
        }
    else
        lspconfig.pyright.setup {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
            settings = {
                python = {
                    venvPath = ".",
                    venv = ".venv",
                    pythonPath = "./.venv/bin/python",
                    analysis = {
                        extraPaths = {"."}
                    }
                }
            }
        }
    end
end })

local null_ls = require("null-ls")
local venv_path = "./.venv/bin"
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black.with {
            prefer_local = venv_path
        },
        null_ls.builtins.formatting.isort.with {
            prefer_local = venv_path
        },
        null_ls.builtins.diagnostics.flake8.with {
            prefer_local = venv_path
        },
        null_ls.builtins.diagnostics.mypy.with {
            prefer_local = venv_path
        },
    }
})

local cmp = require("cmp")
cmp.setup({
    -- REQUIRED - you must specify a snippet engine
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-l>"] = cmp.mapping.complete(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm { select = true },
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        -- { name = "buffer" },
        -- { name = "path" },
    },
    {
        { name = "buffer" }
    })
})

