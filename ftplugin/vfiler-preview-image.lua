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


local pixel_size = "\x1b[6;14;7"

local timg_cmd = { "timg", "-p", "s", "-U" }
table.insert(timg_cmd, "-I")
table.insert(timg_cmd, "-bwhite")
if vim.fn.fnamemodify(path, ":e") == "gif" then
    table.insert(timg_cmd, "--loops=10")
    -- pixel_size = "\x1b[6;20;10"
end
-- TODO: webp alpha

table.insert(timg_cmd, path)

--- Wait opening buffer in preview window
vim.defer_fn(function()
    local winid = vim.fn.bufwinid(bufnr)
    if winid == -1 then
        return
    end

    local config = vim.api.nvim_win_get_config(winid)
    local row_pos = config.row[false] + 3
    local win_height = config.height
    local csi_set_pos = ("\x1b[%d;%dH"):format(row_pos, config.col[false])
    local buffer = csi_set_pos
    local did_exit = false

    -- Save cursor position
    vim.fn.chansend(vim.v.stderr, "\x1b[s")

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
                buffer = buffer:gsub("\x1b%[%d+A", csi_set_pos, 1)
                buffer = buffer:gsub("\x1bPq\x1bPq", "\x1bPq", 1)
                local index = 1
                while index <= #buffer do
                    local len = vim.fn.chansend(vim.v.stderr, buffer:sub(index, index + 32))
                    index = index + len
                end
                buffer = line:sub(pos2 + 1)
            end
        end,
        on_exit = function(_, _, _)
            did_exit = true
        end,
        stdout_buffered = false,
    })

    if jobid <= 0 then
        return
    end

    vim.api.nvim_buf_attach(bufnr, false, {
        on_detach = function()
            did_exit = true
            vim.fn.jobstop(jobid)
            -- Release iTerm sixel resource
            if vim.env.TERM_PROGRAM == "iTerm.app" then
                vim.fn.chansend(vim.v.stderr, "\x1b]1337;ClearScrollback\x1b\\")
            end
            -- Restore cursor position
            vim.fn.chansend(vim.v.stderr, "\x1b[u")
            -- Avoid textlock
            vim.schedule(function()
                -- Redraw display
                vim.cmd [[normal! ]]
            end)
        end,
    })
end, 100)
