return function (items)
    local cmd = "open -a VLC "
    for _, item in pairs(items) do
        cmd = cmd .. " " .. vim.fn.shellescape(item.path)
    end
    vim.fn.system(cmd)
end
