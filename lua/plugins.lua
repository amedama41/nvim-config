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

    -- Tree-sitter --
    use "nvim-treesitter/nvim-treesitter"

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
    group = vim.api.nvim_create_augroup('lsp-settings', { clear = true }),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        local ok, builtin = pcall(require, "telescope.builtin")
        if ok then
            vim.keymap.set("n", "glr", builtin.lsp_references, opts)
            vim.keymap.set("n", "<C-]>", builtin.lsp_definitions, opts)
            vim.keymap.set("n", "gli", builtin.lsp_implementations, opts)
            vim.keymap.set("n", "glt", builtin.lsp_type_definitions, opts)
            vim.keymap.set("n", "gld", function()
                builtin.diagnostics { bufnr = 0 }
            end, opts)
            vim.keymap.set("n", "glD", function()
                builtin.diagnostics { root_dir = true }
            end, opts)
            vim.keymap.set("n", "gls", function()
                builtin.lsp_document_symbols { symbols = { "class", "function", "method" } }
            end, opts)
        else
            vim.keymap.set("n", "glr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, opts)
            -- vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
            vim.keymap.set("n", "gli", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "glt", vim.lsp.buf.type_definition, opts)
        end
        vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "glf", function()
            vim.lsp.buf.format { timeout_ms = 10000 }
        end, opts)
        vim.keymap.set("n", "gln", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "gla", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "ge", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "g]", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, opts)
    end
})

local ok, mason = pcall(require, "mason")
if ok then
    mason.setup()
end
local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok then
    local lspconfig = require("lspconfig")
    mason_lspconfig.setup_handlers({
        function(server)
            lspconfig[server].setup {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            }
        end,
        ["pyright"] = function()
            lspconfig.pyright.setup {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                settings = {
                    python = {
                        pythonPath = "./.venv/bin/python",
                    }
                },
            }
        end,
        ["tsserver"] = function()
            lspconfig.tsserver.setup {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
            }
        end,
    })
end

local ok, null_ls = pcall(require, "null-ls")
if ok then
    local bin_path = "./.venv/bin"
    null_ls.setup({
        diagnostics_format = "#{m} [#{s}]",
        sources = {
            null_ls.builtins.formatting.black.with {
                prefer_local = bin_path
            },
            null_ls.builtins.formatting.isort.with {
                prefer_local = bin_path
            },
            null_ls.builtins.diagnostics.flake8.with {
                prefer_local = bin_path
            },
            null_ls.builtins.diagnostics.mypy.with {
                prefer_local = bin_path
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
            ["<C-c>"] = cmp.mapping.close(),
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

local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if ok then
    treesitter.setup {
        highlight = { enable = true },
        indent = { enable = true },
    }
end

-- VFilerの設定
local open_vfiler_terminal = function(dirpath, args)
    local termname = "term://" .. vim.fn.getbufinfo("%")[1].name
    local termbufs = vim.fn.getbufinfo(termname)
    local job_id = nil
    if next(termbufs) == nil then
        vim.cmd [[
            botright new
            resize 15
        ]]
        job_id = vim.fn.termopen({vim.opt.shell:get()}, { cwd = dirpath })
        vim.cmd("keepalt file " .. termname)
    else
        local termbufinfo = termbufs[1]
        if termbufinfo.hidden == 0 then
            -- 表示済みの場合は表示中のWindowにフォーカスする
            local wids = vim.fn.win_findbuf(termbufinfo.bufnr)
            if next(wids) ~= nil then
                vim.fn.win_gotoid(wids[1])
            end
        else
            -- 非表示の場合は画面分割で開く
            vim.cmd("botright sbuffer " .. termbufinfo.bufnr)
            vim.cmd [[resize 15]]
        end
        job_id = termbufinfo.variables.terminal_job_id
        -- VFilerで開いているディレクトリに移動する
        vim.fn.chansend(
            job_id,
            vim.api.nvim_replace_termcodes("<C-U>", true, true, true)
            .. " cd " .. vim.fn.shellescape(dirpath)
            .. vim.api.nvim_replace_termcodes("<CR>", true, true, true))
    end
    if args ~= "" then
        vim.fn.chansend(
            job_id,
            args .. vim.api.nvim_replace_termcodes("<C-A>", true, true, true))
    end
    vim.cmd [[startinsert]]
end

local ok, vfiler_action = pcall(require, "vfiler/action")
if ok then
    local vfiler_config = require("vfiler/config")
    vfiler_config.unmap("<C-p>")
    vfiler_config.unmap("b")
    vfiler_config.unmap("B")
    vfiler_config.unmap("D")
    vfiler_config.unmap("v")
    vfiler_config.setup({
        options = {
            auto_cd = true,
            auto_resize = true,
            columns = 'indent,icon,name,size,time',
            keep = true,
            name = "vfiler",
            sort = "extension",
            git = {
                enabled = true,
                ignored = false,
                untracked = true,
            },
        },
        mappings = {
            ["gb"] = vfiler_action.list_bookmark,
            ["gB"] = vfiler_action.add_bookmark,
            ["gj"] = vfiler_action.move_cursor_down_sibling,
            ["gk"] = vfiler_action.move_cursor_up_sibling,
            ["gp"] = vfiler_action.toggle_auto_preview,
            ["g/"] = vfiler_action.jump_to_root,
            ["H"] = function(vfiler, context, view)
                local selected_items = view:selected_items()
                local args = ''
                for _, item in pairs(selected_items) do
                    if item.selected then
                        args = args .. ' ' .. vim.fn.shellescape(item.path)
                    end
                end
                vfiler_action.clear_selected_all(vfiler, context, view)
                open_vfiler_terminal(context.root.path, args)
            end,
            ["ip"] = function(vfiler, context, view)
                for key, item in pairs(view:selected_items()) do
                    vim.fn.system("open -a preview " .. vim.fn.shellescape(item.path))
                end
                vfiler_action.clear_selected_all(vfiler, context, view)
            end,
            ["j"] = vfiler_action.move_cursor_down,
            ["k"] = vfiler_action.move_cursor_up,
            ["l"] = vfiler_action.open,
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
            ["<C-d>"] = function(vfiler, context, view)
                if context.in_preview.preview then
                    vfiler_action.scroll_down_preview(vfiler, context, view)
                else
                    vim.cmd("normal! \x04")
                end
            end,
            ["<C-g>"] = function(vfiler, context, view)
                local item = view:get_item()
                print(item.name)
            end,
            ["<C-j>"] = vfiler_action.jump_to_history_directory,
            ["<C-o>"] = function(vfiler, context, view)
                local history = context:directory_history()
                if #history == 0 then
                    return
                end
                local utilities = require("vfiler/actions/utilities")
                utilities.cd(vfiler, context, view, history[1])
            end,
            ["<C-r>"] = function(vfiler, context, view)
                local linked = context.linked
                if not (linked and linked:visible()) then
                    return
                end

                local item = view:get_item()
                local path = vim.fn.fnamemodify(item.path, ":p:h")
                local utilities = require("vfiler/actions/utilities")
                linked:focus()
                linked:update(context)
                linked:do_action(utilities.cd, path)
                vfiler:focus() -- return current window
            end,
            ["<C-u>"] = function(vfiler, context, view)
                if context.in_preview.preview then
                    vfiler_action.scroll_up_preview(vfiler, context, view)
                else
                    vim.cmd("normal! \x15")
                end
            end,
        },
    })
    local keymap_opts = { noremap = true, silent = true }
    local cmd = "VFiler -auto-cd -auto-resize -keep -no-listed"
    .. " -layout=left -name=explorer -width=30 -columns=indent,icon,name,git<CR>"
    vim.api.nvim_set_keymap("n", "<C-\\>e", "<cmd>" .. cmd, keymap_opts)
    vim.api.nvim_create_augroup("vfiler-settings", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = "vfiler-settings",
        pattern = {"vfiler"},
        callback = function()
            vim.keymap.set("x", "<Space>", function()
                local first = vim.fn.line("v")
                local last = vim.fn.line(".")
                if first > last then
                    first, last = last, first
                end
                local view = require('vfiler/vfiler').get(vim.fn.bufnr("%"))._view
                first = math.max(first, view:top_lnum())
                for i = first, last do
                    local item = view:get_item(i)
                    if item then
                        item.selected = not item.selected
                    end
                end
                view:redraw()
                vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, true, true))
            end, { buffer = true })
        end
    })
end

-- telescopeの設定
local ok, telescope = pcall(require, "telescope")
if ok then
    local actions = require("telescope.actions")
    telescope.setup({
        defaults = {
            sorting_strategy = "ascending",
            layout_strategy = "vertical",
            path_display = { "shorten" },
            dynamic_preview_title = true,
            file_ignore_patterns = {
                "^.git/",
                "^.?venv/",
                "%.pyc",
            },
            mappings = {
                n = {
                    ["<C-l>"] = actions.smart_send_to_loclist,
                    ["<C-q>"] = actions.smart_send_to_qflist,
                },
                i = {
                    ["<C-l>"] = actions.smart_send_to_loclist,
                    ["<C-q>"] = actions.smart_send_to_qflist,
                },
            },
        },
        pickers = {
            buffers = {
                mappings = {
                    n = {
                        ["<C-x>"] = actions.delete_buffer,
                    },
                    i = {
                        ["<C-x>"] = actions.delete_buffer,
                    },
                },
            },
        },
    })
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<C-\\>b", function()
        builtin.buffers { only_cwd = true, sort_mru = true }
    end, keymap_opts)
    vim.keymap.set("n", "<C-\\>f", builtin.find_files, keymap_opts)
    vim.keymap.set("n", "<C-\\>g", builtin.live_grep, keymap_opts)
    vim.keymap.set("n", "<C-\\>j", builtin.jumplist, keymap_opts)
    vim.keymap.set("n", "<C-\\>l", builtin.loclist, keymap_opts)
    vim.keymap.set("n", "<C-\\>m", builtin.marks, keymap_opts)
    vim.keymap.set("n", "<C-\\>q", builtin.quickfix, keymap_opts)
    vim.keymap.set("n", "<C-\\>r", builtin.registers, keymap_opts)
    vim.keymap.set("n", "<C-\\>s", builtin.search_history, keymap_opts)
    vim.keymap.set("n", "<C-\\>t", builtin.tagstack, keymap_opts)
    vim.keymap.set("n", "<C-\\><C-\\>", builtin.resume, keymap_opts)
end
