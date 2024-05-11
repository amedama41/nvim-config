local function set_lsp_keymap(ev)
    local builtin = require("telescope.builtin")
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "glr", builtin.lsp_references, opts)
    vim.keymap.set("n", "<C-]>", builtin.lsp_definitions, opts)
    vim.keymap.set("n", "gli", builtin.lsp_implementations, opts)
    vim.keymap.set("n", "glt", builtin.lsp_type_definitions, opts)
    vim.keymap.set("n", "gld", function()
        builtin.diagnostics({ bufnr = 0 })
    end, opts)
    vim.keymap.set("n", "glD", function()
        builtin.diagnostics({ root_dir = true })
    end, opts)

    local filetype = vim.bo[ev.buf].filetype
    local symbols = nil
    if filetype ~= "markdown" then
        symbols = { "class", "function", "method" }
    end
    vim.keymap.set("n", "gls", function()
        builtin.lsp_document_symbols({ symbols = symbols })
    end, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "glf", function()
        vim.lsp.buf.format({ timeout_ms = 10000 })
    end, opts)
    vim.keymap.set("n", "gln", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gla", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "ge", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "g]", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, opts)
end

return {
    "nvim-telescope/telescope.nvim",
    event = { "LspAttach" },
    cmd = { "Telescope" },
    keys = { "<C-\\>" },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = function()
        local actions = require("telescope.actions")
        return {
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
        }
    end,
    config = function(_, opts)
        require("telescope").setup(opts)
        local builtin = require("telescope.builtin")
        local keymap_opts = { noremap = true, silent = true }
        vim.keymap.set("n", "<C-\\>b", builtin.buffers, keymap_opts)
        vim.keymap.set("n", "<C-\\>c", builtin.command_history, keymap_opts)
        vim.keymap.set("n", "<C-\\>f", builtin.find_files, keymap_opts)
        vim.keymap.set("n", "<C-\\>F", function()
            builtin.find_files({ hidden = true, no_ignore = true, no_ignore_parent = true })
        end, keymap_opts)
        vim.keymap.set("n", "<C-\\>g", builtin.live_grep, keymap_opts)
        vim.keymap.set("n", "<C-\\>j", builtin.jumplist, keymap_opts)
        vim.keymap.set("n", "<C-\\>l", builtin.loclist, keymap_opts)
        vim.keymap.set("n", "<C-\\>m", builtin.marks, keymap_opts)
        vim.keymap.set("n", "<C-\\>M", function()
            local section = (vim.v.count == 0 and "ALL") or tostring(vim.v.count)
            builtin.man_pages({ sections = { section } })
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

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("vimrc-lsp-settings", { clear = true }),
            callback = set_lsp_keymap,
        })
    end,
}
