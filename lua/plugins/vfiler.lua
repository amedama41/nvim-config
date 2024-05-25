return {
    "obaland/vfiler.vim",
    config = function()
        local action = require("vfiler/action")
        local vfiler_config = require("vfiler/config")
        vfiler_config.clear_mappings()
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
                    height = vim.o.lines - 6,
                    -- width = vim.o.columns - 30,
                },
            },
            mappings = {
                ["."] = action.toggle_show_hidden,
                ["~"] = action.jump_to_home,
                ["*"] = action.toggle_select_all,
                ["}"] = action.move_cursor_down_sibling,
                ["{"] = action.move_cursor_up_sibling,
                ["a"] = action.new_file,
                ["A"] = action.new_directory,
                ["cc"] = action.copy_to_filer,
                ["C"] = action.copy,
                ["dd"] = action.delete,
                ["gb"] = action.list_bookmark,
                ["gB"] = action.add_bookmark,
                ["gg"] = action.move_cursor_top,
                ["gl"] = action.switch_to_drive,
                ["gp"] = action.toggle_auto_preview,
                ["gs"] = action.toggle_sort,
                ["g/"] = action.jump_to_root,
                ["g<Space>"] = function(_, _, view)
                    local current = vim.fn.line(".")
                    local current_selected = view:get_item(current).selected
                    local top_lnum = view:top_lnum()
                    for line = current, top_lnum, -1 do
                        local item = view:get_item(line)
                        if item.selected ~= current_selected then
                            break
                        end
                        item.selected = not current_selected
                    end
                    view:redraw()
                end,
                -- ['G'] = vfiler_action.move_cursor_bottom,
                ["h"] = action.close_tree_or_cd,
                ["ip"] = function(vfiler, context, view)
                    for _, item in pairs(view:selected_items()) do
                        vim.fn.system("open -a preview " .. vim.fn.shellescape(item.path))
                    end
                    action.clear_selected_all(vfiler, context, view)
                end,
                ["io"] = function(vfiler, context, view)
                    local play_ok, play_items = pcall(require, "play_items")
                    if play_ok then
                        play_items(view:selected_items())
                    end
                    action.clear_selected_all(vfiler, context, view)
                end,
                ["ix"] = action.execute_file,
                ["iX"] = function(vfiler, context, view)
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
                    action.clear_selected_all(vfiler, context, view)
                    action.reload(vfiler, context, view)
                end,
                ["I"] = action.jump_to_directory,
                ["j"] = action.move_cursor_down,
                ["J"] = action.jump_to_directory,
                ["k"] = action.move_cursor_up,
                ["l"] = action.open,
                ["o"] = function(vfiler, context, view)
                    local item = view:get_item()
                    if item.type == "directory" then
                        if item.opened == true then
                            action.close_tree_or_cd(vfiler, context, view)
                        else
                            action.open_tree(vfiler, context, view)
                            -- 開いたツリーの中にカーソルが移動するので元に戻す
                            action.move_cursor_up(vfiler, context, view)
                        end
                    else
                        action.open_by_vsplit(vfiler, context, view)
                    end
                end,
                ["O"] = function(vfiler, context, view)
                    local item = view:get_item()
                    if item.type == "directory" then
                        if item.opened == true then
                            action.close_tree_or_cd(vfiler, context, view)
                        else
                            action.open_tree_recursive(vfiler, context, view)
                            -- 開いたツリーの中にカーソルが移動するので元に戻す
                            action.move_cursor_up(vfiler, context, view)
                        end
                    else
                        action.open_by_tabpage(vfiler, context, view)
                    end
                end,
                ["p"] = action.toggle_preview,
                ["P"] = action.paste,
                ["r"] = action.rename,
                ["s"] = action.open_by_split,
                ["S"] = action.change_sort,
                ["u"] = function(vfiler, context, view)
                    action.move_cursor_top_sibling(vfiler, context, view)
                    action.move_cursor_up(vfiler, context, view)
                end,
                ["U"] = action.clear_selected_all,
                ["xx"] = action.move_to_filer,
                ["X"] = action.move,
                ["yy"] = action.yank_path,
                ["yp"] = function(_, _, view)
                    local item = view:get_item()
                    if item.parent then
                        local register = (vim.v.register == [["]] and "+") or vim.v.register
                        vim.fn.setreg(register or "+", item.parent.path, "")
                        print(([[Yanked path - "%s"]]):format(item.parent.path))
                    end
                end,
                ["YY"] = action.yank_name,
                ["<C-b>"] = function(vfiler, context, view)
                    local preview = context.in_preview.preview
                    if preview and preview.opened then
                        action.scroll_up_preview(vfiler, context, view)
                    else
                        vim.cmd("normal! \x02")
                    end
                end,
                ["<C-f>"] = function(vfiler, context, view)
                    local preview = context.in_preview.preview
                    if preview and preview.opened then
                        action.scroll_down_preview(vfiler, context, view)
                    else
                        vim.cmd("normal! \x06")
                    end
                end,
                ["<C-g>"] = function(_, _, view)
                    local item = view:get_item()
                    print(item.path)
                end,
                ["<C-h>"] = action.change_to_parent,
                ["<C-j>"] = action.jump_to_history_directory,
                ["<C-k>"] = function(vfiler, context, view)
                    local selected_items = view:selected_items()
                    ---@type string?
                    local args = ""
                    for _, item in pairs(selected_items) do
                        if item.selected then
                            args = args .. " " .. vim.fn.shellescape(item.path)
                        end
                    end
                    action.clear_selected_all(vfiler, context, view)
                    if args == "" then
                        args = nil
                    end
                    require("lazy").load({
                        plugins = "scallop.nvim",
                        wait = true,
                    })
                    require("scallop").open_edit(args, context.root.path)
                end,
                ["<C-l>"] = action.reload_all_dir,
                ["<C-o>"] = function() end,
                ["<C-r>"] = action.sync_with_current_filer,
                ["<Tab>"] = action.switch_to_filer,
                ["<CR>"] = action.open,
                ["<S-Space>"] = function(vfiler, context, view)
                    action.toggle_select(vfiler, context, view)
                    action.move_cursor_up(vfiler, context, view)
                end,
                ["<Space>"] = function(vfiler, context, view)
                    action.toggle_select(vfiler, context, view)
                    action.move_cursor_down(vfiler, context, view)
                end,
            },
        })
        require("vfiler/action").setup({
            hook = {
                read_preview_file = require("read_preview_file"),
            },
        })
        require("vfiler/extensions/menu/config").setup({
            options = {
                floating = {
                    minwidth = 100,
                },
            },
        })
        require("vfiler/extensions/bookmark/config").setup({
            options = {
                floating = {
                    minwidth = 100,
                },
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
    end,
}
