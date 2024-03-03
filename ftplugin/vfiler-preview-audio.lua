local bufnr = vim.fn.bufnr("%")
local bufname = vim.fn.bufname(bufnr)

local pos1, pos2 = bufname:find("vfiler%-preview%:")
if pos1 == nil then
    return
end

local path = bufname:sub(pos2 + 1)

local jobid = vim.fn.jobstart({ "afplay", path }, {
    clear_env = true,
    detach = false,
    pty = false,
    stdin = nil,
})
if jobid > 0 then
    vim.api.nvim_buf_attach(bufnr, false, {
        on_detach = function()
            vim.fn.jobstop(jobid)
        end,
    })
end
