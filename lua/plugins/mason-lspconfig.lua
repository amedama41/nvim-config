return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        {
            "williamboman/mason.nvim",
            opts = {
                registries = {
                    "lua:my-mason-registry.index",
                    "github:mason-org/mason-registry",
                },
            },
        },
        {
            "creativenull/efmls-configs-nvim",
            tag = "v1.7.0",
            dependencies = "neovim/nvim-lspconfig",
        },
    },
    config = function()
        vim.lsp.set_log_level("off")
        local lspconfig = require("lspconfig")
        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup_handlers({
            function(server)
                lspconfig[server].setup({
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                    single_file_mode = false,
                })
            end,
            ["ts_ls"] = function()
                lspconfig.ts_ls.setup({
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
                    single_file_mode = false,
                })
            end,
            ["rust_analyzer"] = function()
                lspconfig.rust_analyzer.setup({
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                    single_file_mode = false,
                    cargo = {
                        loadOutDirsFromCheck = true,
                    },
                })
            end,
            ["efm"] = function()
                local env = require("env")
                local efmls_configs_ok, _ = pcall(require, "efmls-configs")
                local merge_config = function(config1, config2)
                    return vim.tbl_extend("force", config1, config2)
                end
                if efmls_configs_ok then
                    local py_env = env.python_env

                    lspconfig.efm.setup({
                        init_options = {
                            documentFormatting = true,
                            documentRangeFormatting = true,
                        },
                        filetypes = { "python" },
                        settings = {
                            rootMarkers = {
                                ".git/",
                                "pyproject.toml",
                                "requirements.txt",
                            },
                            languages = {
                                python = {
                                    merge_config(require("efmls-configs.linters.mypy"), { env = py_env }),
                                    merge_config(require("efmls-configs.linters.flake8"), {
                                        env = py_env,
                                        lintCategoryMap = { E = "W", W = "W", I = "I", N = "N" },
                                    }),
                                    merge_config(require("efmls-configs.formatters.black"), { env = py_env }),
                                    merge_config(require("efmls-configs.formatters.isort"), { env = py_env }),
                                },
                            },
                        },
                    })
                end
            end,
        })
    end,
}
