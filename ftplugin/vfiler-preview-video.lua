if not vim.fn.executable("timg") then
    return
end

local bufnr = vim.fn.bufnr("%")
local bufname = vim.fn.bufname(bufnr)

local path
do
    local pos1, pos2 = bufname:find("vfiler%-preview%:")
    if pos1 == nil then
        return
    end
    path = bufname:sub(pos2 + 1)
end


local pixel_size = "\x1b[6;20;10"

local timg_cmd = { "timg", "-p", "s", "-U" }
table.insert(timg_cmd, "-a")
table.insert(timg_cmd, "-V")
-- TODO: alpha

table.insert(timg_cmd, path)

--- Wait opening buffer in preview window
vim.defer_fn(function()
    local winid = vim.fn.bufwinid(bufnr)
    if winid == -1 then
        return
    end

    local config = vim.api.nvim_win_get_config(winid)
    local row_pos = config.row[false] + config.height / 2 + 3
    local win_height = math.floor(config.height / 2)
    local csi_set_pos = ("\x1b[%d;%dH"):format(row_pos, config.col[false] + 3)

    local did_exit = false
    local buffer = ""
    local write_queue = {}
    local write_callback
    local stderr = vim.loop.new_tty(2, false)
    write_callback = function(err)
        if did_exit then
            return
        end
        if err then
            print(err)
        end
        table.remove(write_queue, 1)
        if #write_queue > 0 then
            stderr:write(write_queue[1], write_callback)
        end
    end

    local jobid = vim.fn.jobstart(timg_cmd, {
        clear_env = true,
        pty = true,
        width = config.width,
        height = win_height,
        on_stdout = function(jobid, data, _)
            if did_exit then
                return
            end

            for _, line in pairs(data) do
                if line == "" then
                    return
                elseif line == "\x1b[16t" then
                    vim.fn.chansend(jobid, pixel_size)
                    return
                elseif line == "\x1b[>q\x1b[5n" then
                    vim.fn.chansend(jobid, "\x1bP>|libvterm(0.3)\x1b\\\x1b[0n")
                    return
                elseif line == "\x1b]11;?\x1b\\" then
                    vim.fn.chansend(jobid, "\x1b]11;rgb:3333/3333/3333\x1b\\")
                    return
                end

                local pos1, pos2 = line:find("\x1b\\")
                if pos1 == nil then
                    buffer = buffer .. line
                    return
                end

                buffer = buffer .. line:sub(1, pos2)
                -- vim.fn.appendbufline(1, "$", buffer)
                local sixel_pos = buffer:find("\x1bPq\x1bPq")
                if sixel_pos ~= nil then
                    buffer = buffer:sub(sixel_pos + 3)
                    -- 25: hide cursor
                    -- 80: show sixel in other window
                    -- 7730: sixel scroll left mode
                    -- 8452: sixel scroll right mode
                    buffer = "\x1b[?25l\x1b[80h\x1b[?7730h\x1b[?8452l" .. buffer
                    buffer = csi_set_pos .. buffer
                    -- vim.fn.appendbufline(1, "$", buffer)
                    table.insert(write_queue, buffer)
                    if #write_queue == 1 then
                        stderr:write(write_queue[1], write_callback)
                    end
                end
                buffer = line:sub(pos2 + 1)
            end
        end,
        stdout_buffered = false,
    })

    if jobid <= 0 then
        stderr:close()
        return
    end

    vim.api.nvim_buf_attach(bufnr, false, {
        on_detach = function()
            did_exit = true
            stderr:close()
            vim.fn.jobstop(jobid)
            -- Release iTerm sixel resource
            if vim.env.TERM_PROGRAM == "iTerm.app" then
                vim.fn.chansend(vim.v.stderr, "\x1b\\\x1b]1337;ClearScrollback\x1b\\")
            end
            -- Avoid textlock
            vim.schedule(function()
                -- Redraw display
                vim.cmd [[normal! ]]
            end)
        end,
    })
end, 100)
