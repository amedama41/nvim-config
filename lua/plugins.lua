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

local function setup_deol()
    vim.cmd [[
        let g:deol#prompt_pattern = "Macbook\\$\\s"
        let g:deol#floating_border = "rounded"
        let g:deol#external_history_path = "~/.bash_history"
        let g:deol#shell_history_max = 10000
    ]]
end

require("packer").startup(function(use)
    use "wbthomason/packer.nvim"

    -- LSP関連
    use "neovim/nvim-lspconfig"
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-path"
    use "hrsh7th/vim-vsnip"
    use "amarakon/nvim-cmp-buffer-lines"
    use { "creativenull/efmls-configs-nvim", tag = "v1.*", requires = "neovim/nvim-lspconfig" }

    -- Tree-sitter --
    use "nvim-treesitter/nvim-treesitter"
    -- use "nvim-treesitter/playground"

    -- ファイラー
    use "obaland/vfiler.vim"
    -- Fuzzy finder
    use { "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" }
    use { "LukasPietzschmann/telescope-tabs",
        requires = "nvim-telescope/telescope.nvim",
        config = function()
            require("telescope").load_extension "telescope-tabs"
            local telescope_tabs = require("telescope-tabs")
            telescope_tabs.setup({
                entry_formatter = function(tab_id, bufids, names, paths, is_current)
                    local tabnr = vim.api.nvim_tabpage_get_number(tab_id)
                    return ("%s %d: %s"):format(is_current and "%" or " ", tabnr, vim.fn.getcwd(1, tabnr))
                end,
                entry_ordinal = function(tab_id, bufids, names, paths, is_current)
                    local tabnr = vim.api.nvim_tabpage_get_number(tab_id)
                    return ("%d: %s"):format(tabnr, vim.fn.getcwd(1, tabnr))
                end,
                close_tab_shortcut_i = "<C-g><C-d>",
                close_tab_shortcut_n = "<C-g><C-d>",
            })
            vim.keymap.set("n", "<C-\\><C-t>", function()
                telescope_tabs.list_tabs()
            end, { noremap = true, silent = true })
            vim.keymap.set("n", "<C-\\><C-^>", function()
                telescope_tabs.go_to_previous()
            end, { noremap = true, silent = true })
        end,
    }
    -- Terminal
    use { "Shougo/deol.nvim", config = setup_deol, disable = true }
    use "amedama41/scallop.nvim"
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
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("vimrc-lsp-settings", { clear = true }),
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

            local filetype = vim.bo[ev.buf].filetype
            local symbols = nil
            if filetype ~= "markdown" then
                symbols = { "class", "function", "method", }
            end
            vim.keymap.set("n", "gls", function()
                builtin.lsp_document_symbols { symbols = symbols }
            end, opts)
        else
            vim.keymap.set("n", "glr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, opts)
            -- vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
            vim.keymap.set("n", "gli", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "glt", vim.lsp.buf.type_definition, opts)
        end
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
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
    mason.setup {
        registries = {
            "lua:my-mason-registry.index",
            "github:mason-org/mason-registry",
        }
    }
end
local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok then
    -- vim.lsp.set_log_level("debug")
    vim.lsp.set_log_level("off")
    local lspconfig = require("lspconfig")
    local lspconfig_configs = require("lspconfig.configs")
    if not lspconfig_configs.bashls_mod then
        lspconfig_configs.bashls_mod = {
            default_config = {
                cmd = { "bash-language-server-mod", "start" },
                filetypes = { "bash", "bash.*" },
                single_file_support = true,
                root_dir = function()
                    return vim.fn.getcwd()
                end,
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            },
        }
    end
    local server_mappings = require("mason-lspconfig.mappings.server")
    server_mappings.lspconfig_to_package["bashls_mod"] = "bash-language-server-mod"
    server_mappings.package_to_lspconfig["bash-language-server-mod"] = "bashls_mod"
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
        ["efm"] = function()
            local efmls_configs_ok, _ = pcall(require, "efmls-configs")
            local merge_config = function(config1, config2)
                local config = {}
                for k, v in pairs(config1) do
                    config[k] = v
                end
                for k, v in pairs(config2) do
                    config[k] = v
                end
                return config
            end
            if efmls_configs_ok then
                local py_env = {
                    "PATH=./test_modules/bin:./.venv/bin:" .. vim.env.PATH,
                    "PYTHONPATH=./test_modules",
                }

                lspconfig.efm.setup {
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
                }
            end
        end,
    })
end

local ok, cmp = pcall(require, "cmp")
if ok then
    local feedkeys = require("cmp.utils.feedkeys")
    local keymap = require("cmp.utils.keymap")
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
            },
            {
                { name = "buffer" },
            })
    })
    cmp.setup.filetype({ "bash.scallopedit" }, {
        sources = {
            { name = "nvim_lsp" },
            {
                name = "path",
                option = {
                    get_cwd = function()
                        return vim.fn.getcwd()
                    end
                },
            },
            {
                name = "buffer-lines",
            },
        },
        {
            { name = "buffer" },
            {
                name = "path",
                option = {
                    get_cwd = function()
                        return vim.fn.getcwd()
                    end
                },
            },
            {
                name = "buffer-lines",
            },
        }
    })
end

local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if ok then
    treesitter.setup {
        highlight = { enable = true },
        indent = { enable = true },
    }
end

local open_terminal = nil
local ok, scallop = pcall(require, "scallop")
if ok then
    require("scallop.configs").setup({
        options = {
            prompt_pattern = "Macbook\\$\\s",
            history_filepath = "~/.bash_history",
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

    open_terminal = function(dirpath, args)
        -- local columns = vim.opt.columns:get()
        -- local lines = vim.opt.lines:get()
        scallop.start_terminal_edit(args, dirpath)
    end
    vim.keymap.set("n", "g<C-k>", function()
        scallop.start_terminal()
    end, { noremap = true, silent = true })
else
    open_terminal = function(dirpath, args)
        local termname = "term://" .. vim.fn.getbufinfo("%")[1].name
        local termbufs = vim.fn.getbufinfo(termname)
        local job_id = nil
        if next(termbufs) == nil then
            vim.cmd [[
                botright new
                resize 15
            ]]
            job_id = vim.fn.termopen({ vim.opt.shell:get() }, { cwd = dirpath })
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
            vim.cmd("lcd " .. dirpath)
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
end
vim.keymap.set("n", "<C-k>", function()
    open_terminal()
end, { noremap = true, silent = true })

-- VFilerの設定
local ok, vfiler_action = pcall(require, "vfiler/action")
if ok then
    local vfiler_config = require("vfiler/config")
    vfiler_config.unmap("<C-p>")
    vfiler_config.unmap("b")
    vfiler_config.unmap("B")
    vfiler_config.unmap("D")
    vfiler_config.unmap("N")
    vfiler_config.unmap("v")
    vfiler_config.setup({
        options = {
            auto_cd = true,
            auto_resize = true,
            columns = "indent,icon,name,size,time",
            keep = false,
            name = "vfiler",
            session = 'share',
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
            ["gn"] = vfiler_action.new_file,
            ["gp"] = vfiler_action.toggle_auto_preview,
            ["g/"] = vfiler_action.jump_to_root,
            ["H"] = function(vfiler, context, view)
                local selected_items = view:selected_items()
                local args = ""
                for _, item in pairs(selected_items) do
                    if item.selected then
                        args = args .. " " .. vim.fn.shellescape(item.path)
                    end
                end
                vfiler_action.clear_selected_all(vfiler, context, view)
                if args == "" then
                    args = nil
                end
                open_terminal(context.root.path, args)
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
            ["X"] = function(vfiler, context, view)
                if vim.fn.executable("unar") then
                    local selected_items = view:selected_items()
                    local jobids = {}
                    local run_items = {}
                    for _, item in pairs(selected_items) do
                        local jobid = vim.fn.jobstart({ "unar", item.path }, {
                            clear_env = true,
                            cwd = vim.fn.fnamemodify(item.path, ":h"),
                            detach = true,
                            pty = false,
                            stdin = nil,
                        })
                        if jobid > 0 then
                            table.insert(jobids, jobid)
                            table.insert(run_items, item.path)
                        else
                            vim.print(([[failed to run unar for "%s"]]):format(item.path))
                        end
                    end
                    local exitcodes = vim.fn.jobwait(jobids, 500)
                    for i, exitcode in pairs(exitcodes) do
                        if exitcode > 0 then
                            vim.print(([[failed to unar for "%s" (%d)]]):format(run_items[i], exitcode))
                        end
                    end
                end
                vfiler_action.clear_selected_all(vfiler, context, view)
                vfiler_action.reload(vfiler, context, view)
            end,
            ["yp"] = function(vfiler, context, view)
                local item = view:get_item()
                if item.parent then
                    local register = (vim.v.register == [["]] and "+") or vim.v.register
                    vim.fn.setreg(register or "+", item.parent.path, "")
                    print(([[Yanked path - "%s"]]):format(item.parent.path))
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
                print(item.path)
            end,
            ["<C-h>"] = vfiler_action.change_to_parent,
            ["<C-j>"] = vfiler_action.jump_to_history_directory,
            ["<C-l>"] = vfiler_action.reload_all_dir,
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
    local menu_action = require("vfiler/extensions/menu/action")
    require("vfiler/extensions/menu/config").setup({
        options = {
            floating = {
                minwidth = 100,
            }
        },
        mappings = {
            ["<C-p>"] = menu_action.loop_cursor_up,
            ["<C-n>"] = menu_action.loop_cursor_down,
        },
    })
    local bookmark_action = require("vfiler/extensions/bookmark/action")
    require("vfiler/extensions/bookmark/config").setup({
        options = {
            floating = {
                minwidth = 100,
            }
        },
        mappings = {
            ["o"] = bookmark_action.open_tree,
            ["<C-p>"] = bookmark_action.smart_cursor_up,
            ["<C-n>"] = bookmark_action.smart_cursor_down,
        },
    })
    local keymap_opts = { noremap = true, silent = true }
    local cmd = table.concat({
        "VFiler",
        "-auto-cd",
        "-auto-resize",
        "-find-file",
        "-keep",
        "-session=buffer",
        "-no-listed",
        "-layout=left",
        "-name=explorer",
        "-width=30",
        "-columns=indent,icon,name,git",
    }, " ")
    vim.api.nvim_set_keymap("n", "<C-\\>e", "<cmd>" .. cmd .. "<CR>", keymap_opts)
    local group = vim.api.nvim_create_augroup("vimrc-vfiler-settings", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "vfiler" },
        callback = function()
            vim.keymap.set("x", "<Space>", function()
                local first = vim.fn.line("v")
                local last = vim.fn.line(".")
                if first > last then
                    first, last = last, first
                end
                local view = require("vfiler/vfiler").get(vim.fn.bufnr("%"))._view
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
            path_display = { shorten = 2 },
            dynamic_preview_title = true,
            file_ignore_patterns = {
                "^.git/",
                "^.?venv/",
                "%.pyc",
            },
            mappings = {
                n = {
                    ["j"] = actions.move_selection_next,
                    ["<C-n>"] = actions.move_selection_next,
                    ["k"] = actions.move_selection_previous,
                    ["<C-p>"] = actions.move_selection_previous,
                    ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                    ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                    ["H"] = actions.move_to_top,
                    ["M"] = actions.move_to_middle,
                    ["L"] = actions.move_to_bottom,
                    ["U"] = actions.drop_all,
                    ["*"] = actions.toggle_all,
                    ["<C-b>"] = actions.preview_scrolling_up,
                    ["<C-f>"] = actions.preview_scrolling_down,
                    ["<M-h>"] = actions.preview_scrolling_left,
                    ["<M-l>"] = actions.preview_scrolling_right,
                    ["<C-k>"] = actions.results_scrolling_left,
                    ["<C-j>"] = actions.results_scrolling_right,
                    ["q"] = actions.close,
                    ["<ESC>"] = actions.close,
                    ["?"] = actions.which_key,
                    ["<C-g><C-l>"] = actions.smart_send_to_loclist,
                    ["<C-g><C-q>"] = actions.smart_send_to_qflist,
                    ["<C-u>"] = false,
                    ["<C-d>"] = false,
                },
                i = {
                    ["<C-n>"] = actions.move_selection_next,
                    ["<C-p>"] = actions.move_selection_previous,
                    ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                    ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                    ["<C-g>H"] = actions.move_to_top,
                    ["<C-g>M"] = actions.move_to_middle,
                    ["<C-g>L"] = actions.move_to_bottom,
                    ["<C-g>U"] = actions.drop_all,
                    ["<C-g>*"] = actions.toggle_all,
                    ["<C-b>"] = actions.preview_scrolling_up,
                    ["<C-f>"] = actions.preview_scrolling_down,
                    ["<M-h>"] = actions.preview_scrolling_left,
                    ["<M-l>"] = actions.preview_scrolling_right,
                    ["<C-k>"] = actions.results_scrolling_left,
                    ["<C-j>"] = actions.results_scrolling_right,
                    ["<C-g><C-l>"] = actions.smart_send_to_loclist,
                    ["<C-g><C-q>"] = actions.smart_send_to_qflist,
                    ["<C-x><C-n>"] = actions.cycle_history_next,
                    ["<C-x><C-p>"] = actions.cycle_history_prev,
                    ["<C-u>"] = false,
                    ["<C-d>"] = false,
                },
            },
        },
        pickers = {
            grep_string = { word_match = "-s" },
            git_commits = {
                git_command = { "git", "log", "--pretty=tformat:%h %ad %s", "--date=short", "--", "." },
            },
            git_bcommits = {
                git_command = { "git", "log", "--pretty=tformat:%h %ad %s", "--date=short" },
            },
            git_bcommits_range = {
                git_command = { "git", "log", "--pretty=tformat:%h %ad %s", "--date=short", "--no-patch", "-L" },
            },
            oldfiles = { only_cwd = true },
            buffers = {
                only_cwd = true,
                sort_lastused = true,
                sort_mru = true,
                mappings = {
                    n = {
                        ["D"] = actions.delete_buffer,
                    },
                },
            },
            lsp_references = { include_current_line = true },
        },
    })
    local builtin = require("telescope.builtin")
    local keymap_opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<C-\\>b", builtin.buffers, keymap_opts)
    vim.keymap.set("n", "<C-\\>f", builtin.find_files, keymap_opts)
    vim.keymap.set("n", "<C-\\>F", function()
        builtin.find_files { hidden = true, no_ignore = true, no_ignore_parent = true }
    end, keymap_opts)
    vim.keymap.set("n", "<C-\\>g", builtin.live_grep, keymap_opts)
    vim.keymap.set("n", "<C-\\>j", builtin.jumplist, keymap_opts)
    vim.keymap.set("n", "<C-\\>l", builtin.loclist, keymap_opts)
    vim.keymap.set("n", "<C-\\>m", builtin.marks, keymap_opts)
    vim.keymap.set("n", "<C-\\>M", function()
        local section = (vim.v.count == 0 and "ALL") or tostring(vim.v.count)
        builtin.man_pages { sections = { section } }
    end, keymap_opts)
    vim.keymap.set("n", "<C-\\>o", builtin.oldfiles, keymap_opts)
    vim.keymap.set("n", "<C-\\>q", builtin.quickfix, keymap_opts)
    vim.keymap.set("n", "<C-\\>r", builtin.registers, keymap_opts)
    vim.keymap.set("n", "<C-\\>s", builtin.search_history, keymap_opts)
    vim.keymap.set("n", "<C-\\>t", builtin.tagstack, keymap_opts)
    vim.keymap.set({ "n", "x" }, "<C-\\>*", builtin.grep_string, keymap_opts)
    vim.keymap.set("n", "<C-\\><C-\\>", builtin.resume, keymap_opts)
    vim.keymap.set("n", "<C-\\>C", builtin.git_commits, keymap_opts)
    vim.keymap.set("n", "<C-\\>B", builtin.git_bcommits, keymap_opts)
    vim.keymap.set("x", "<C-\\>B", builtin.git_bcommits_range, keymap_opts)
    vim.keymap.set("n", "<C-\\>GB", builtin.git_branches, keymap_opts)
    vim.keymap.set("n", "<C-\\>GS", builtin.git_stash, keymap_opts)
end
