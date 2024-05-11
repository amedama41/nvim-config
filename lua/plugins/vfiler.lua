return {
    "obaland/vfiler.vim",
    config = function()
        local vfiler_action = require("vfiler/action")
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
                session = "share",
                sort = "extension",
                git = {
                    enabled = true,
                    ignored = false,
                    untracked = true,
                },
                preview = {
                    -- layout = "right",
                    -- height = vim.o.lines - 5,
                    -- width = vim.o.columns - 30,
                },
            },
            mappings = {
                ["gb"] = vfiler_action.list_bookmark,
                ["gB"] = vfiler_action.add_bookmark,
                ["gj"] = vfiler_action.move_cursor_down_sibling,
                ["gJ"] = vfiler_action.move_cursor_top_sibling,
                ["gk"] = vfiler_action.move_cursor_up_sibling,
                ["gn"] = vfiler_action.new_file,
                ["gp"] = vfiler_action.toggle_auto_preview,
                ["g/"] = vfiler_action.jump_to_root,
                ["H"] = function(vfiler, context, view)
                    local selected_items = view:selected_items()
                    ---@type string?
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
                    require("lazy").load({
                        plugins = "scallop.nvim",
                        wait = true,
                    })
                    require("scallop").start_terminal_edit(args, context.root.path)
                end,
                ["ip"] = function(vfiler, context, view)
                    for _, item in pairs(view:selected_items()) do
                        vim.fn.system("open -a preview " .. vim.fn.shellescape(item.path))
                    end
                    vfiler_action.clear_selected_all(vfiler, context, view)
                end,
                ["io"] = function(vfiler, context, view)
                    local play_ok, play_items = pcall(require, "play_items")
                    if play_ok then
                        play_items(view:selected_items())
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
                ["yp"] = function(_, _, view)
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
                ["<C-g>"] = function(_, _, view)
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
        require("vfiler/action").setup({
            hook = {
                read_preview_file = require("read_preview_file"),
            },
        })
        local menu_action = require("vfiler/extensions/menu/action")
        require("vfiler/extensions/menu/config").setup({
            options = {
                floating = {
                    minwidth = 100,
                },
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
                },
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
            end,
        })
    end,
}
