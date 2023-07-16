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

    -- LSP関連
    use "neovim/nvim-lspconfig"
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/vim-vsnip"
    use { "jose-elias-alvarez/null-ls.nvim", requires = "nvim-lua/plenary.nvim" }

    -- ファイラー
    use "obaland/vfiler.vim"
    -- Fuzzy finder
    use { "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" }
    -- Git diff
    use "sindrets/diffview.nvim"
    -- Terraform
    use "hashivim/vim-terraform"

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require("packer").sync()
    end
end)

-- LSP関連の設定
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        vim.keymap.set("n", "gF", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        vim.keymap.set("n", "<C-]>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        -- vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
        vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
        vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
        vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
        vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    end
})

local ok, mason = pcall(require, "mason")
if ok then
    mason.setup()
end
local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok then
    mason_lspconfig.setup_handlers({ function(server)
        local lspconfig = require("lspconfig")
        if server == "pyright" then
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
        else
            lspconfig[server].setup {
                capabilities = require("cmp_nvim_lsp").default_capabilities()
            }
        end
    end })
end

local ok, null_ls = pcall(require, "null-ls")
if ok then
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
end

local ok, cmp = pcall(require, "cmp")
if ok then
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
end

-- VFilerの設定
local open_vfiler_terminal = function(dirpath)
    local termbufinfo = nil
    -- VFilerから開いたTerminalを探す
    local termbufs = vim.fn.getbufinfo('term://*')
    for key, bufinfo in pairs(termbufs) do
        local filetype = vim.fn.getbufvar(bufinfo.bufnr, '&filetype')
        if filetype == 'vfiler-terminal' then
            termbufinfo = bufinfo
            break
        end
    end
    if termbufinfo == nil then
        vim.cmd [[botright new]]
        vim.cmd("lcd " .. dirpath)
        vim.cmd [[terminal]]
        vim.cmd [[set filetype=vfiler-terminal]]
    else
        if termbufinfo.hidden == 0 then
            -- 表示済みの場合は表示中のWindowにフォーカスする
            local wids = vim.fn.win_findbuf(termbufinfo.bufnr)
            if next(wids) ~= nil then
                vim.fn.win_gotoid(wids[1])
            end
        else
            -- 非表示の場合は画面分割で開く
            vim.cmd("botright sbuffer " .. termbufinfo.bufnr)
        end
        -- VFilerで開いているディレクトリに移動する
        vim.fn.chansend(
            termbufinfo.variables.terminal_job_id,
            " cd " .. vim.fn.shellescape(dirpath) .. "\n")
    end
    vim.cmd [[startinsert]]
end

local ok, vfiler_action = pcall(require, "vfiler/action")
if ok then
    local vfiler_config = require("vfiler/config")
    vfiler_config.setup({
        options = {
            auto_cd = true,
            auto_resize = true,
            keep = true,
            name = "vfiler",
        },
        mappings = {
            ["l"] = vfiler_action.open,
            ["j"] = vfiler_action.move_cursor_down,
            ["k"] = vfiler_action.move_cursor_up,
            ["o"] = function(vfiler, context, view)
                local item = view:get_item()
                if item.type == "directory" then
                    if item.opened == true then
                        vfiler_action.close_tree_or_cd(vfiler, context, view)
                    else
                        vfiler_action.open_tree(vfiler, context, view)
                        -- 開いたツリーの中にカーソルが移動するので元に戻す
                        vfiler_action.move_cursor_up(vfiler, context, view)
                    end
                else
                    vfiler_action.open_by_vsplit(vfiler, context, view)
                end
            end,
            ["O"] = function(vfiler, context, view)
                local item = view:get_item()
                if item.type == "directory" then
                    if item.opened == true then
                        vfiler_action.close_tree_or_cd(vfiler, context, view)
                    else
                        vfiler_action.open_tree_recursive(vfiler, context, view)
                        -- 開いたツリーの中にカーソルが移動するので元に戻す
                        vfiler_action.move_cursor_up(vfiler, context, view)
                    end
                else
                    vfiler_action.open_by_tabpage(vfiler, context, view)
                end
            end,
            ["gp"] = vfiler_action.toggle_auto_preview,
            ["g/"] = vfiler_action.jump_to_root,
            ["ip"] = function(vfiler, context, view)
                for key, item in pairs(view:selected_items()) do
                    vim.fn.system("open -a preview " .. vim.fn.shellescape(item.path))
                end
                vfiler_action.clear_selected_all(vfiler, context, view)
            end,
            ["io"] = function(vfiler, context, view)
                local cmd = "open -a VLC --args"
                for key, item in pairs(view:selected_items()) do
                    cmd = cmd .. " " .. vim.fn.shellescape(item.path)
                end
                vim.fn.system(cmd)
                vfiler_action.clear_selected_all(vfiler, context, view)
            end,
            ["H"] = function(vfiler, context, view)
                local item = view:get_item()
                open_vfiler_terminal(item.parent.path)
            end,
            ["<C-r>"] = function(vfiler, context, view)
                local linked = context.linked
                if not (linked and linked:visible()) then
                    return
                end

                local item = view:get_item()
                local path = vim.fn.fnamemodify(item.path, ":p:h")
                local api = require("vfiler/actions/api")
                linked:focus()
                linked:update(context)
                linked:do_action(api.cd, path)
                vfiler:focus() -- return current window
            end,
        },
    })
    vfiler_config.unmap("<C-p>")
    vfiler_config.unmap("D")
    local keymap_opts = { noremap = true, silent = true }
    local cmd = "VFiler -auto-cd -auto-resize -keep "
    .. "-layout=left -name=explorer -width=30 -columns=indent,icon,name<CR>"
    vim.api.nvim_set_keymap("n", "<C-\\>e", "<cmd>" .. cmd, keymap_opts)
end

-- telescopeの設定
local ok, telescope = pcall(require, "telescope")
if ok then
    telescope.setup({
        defaults = {
            sorting_strategy = "ascending",
            layout_strategy = "vertical",
            file_ignore_patterns = {
                "^.git/",
                "^.?venv/",
                "%.pyc",
            },
        },
    })
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<C-\\>b", builtin.buffers, keymap_opts)
    vim.keymap.set("n", "<C-\\>f", builtin.find_files, keymap_opts)
    vim.keymap.set("n", "<C-\\>g", builtin.live_grep, keymap_opts)
    vim.keymap.set("n", "<C-\\>m", builtin.marks, keymap_opts)
    vim.keymap.set("n", "<C-\\>q", builtin.quickfix, keymap_opts)
    vim.keymap.set("n", "<C-\\>r", builtin.registers, keymap_opts)
    vim.keymap.set("n", "<C-\\>s", builtin.search_history, keymap_opts)
end
