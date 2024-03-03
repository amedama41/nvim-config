---start job synchronously
---@param cmd table
---@param timeout_ms number
---@param pty boolean
---@return integer
---@return table
local function sync_jobstart(cmd, timeout_ms, pty)
    local lines = {}
    local jobid = vim.fn.jobstart(cmd, {
        clear_env = true,
        detach = false,
        pty = pty,
        stdin = nil,
        on_stdout = function(chanid, data, name)
            if data[1] ~= "" then
                lines = data
            end
        end,
        on_stderr = function(chanid, data, name)
            if data[1] ~= "" then
                lines = data
            end
        end,
        stdout_buffered = true,
        stderr_buffered = true,
    })
    local exitcode = vim.fn.jobwait({ jobid }, timeout_ms)[1]
    if exitcode == -1 then
        vim.fn.jobstop(jobid)
    end
    return exitcode, lines
end

---return mediatype and subtype
---@param path string
---@return string
---@return string
local function get_filetype(path)
    local exitcode, lines = sync_jobstart({ "file", "-Ib", path }, 1000, false)
    if exitcode ~= 0 or lines[1] == "" then
        return "", ""
    end
    local mime = vim.fn.matchstr(lines[1], "^\\w\\+/[^; ]\\+")
    print(mime)
    local result = vim.fn.split(mime, "/")
    local mediatype, subtype = result[1], result[2]
    return mediatype, subtype
end

---return true if path is video
---@param path string
---@param mediatype string
---@param subtype string
---@return boolean
local function is_video(path, mediatype, subtype)
    if mediatype == "video" then
        return true
    end
    if mediatype == "application" then
        if subtype == "vnd.rn-realmedia" then
            return true
        end
        if subtype == "octet-stream" and vim.fn.fnamemodify(path, ":e") == "ts" then
            return true
        end
    end
    return false
end

local function read_preview_file(path, default_read_file_func)
    local mediatype, subtype = get_filetype(path)
    if mediatype == "text" then
        return default_read_file_func(path)
    end
    if mediatype == "audio" or is_video(path, mediatype, subtype) then
        local _, lines = sync_jobstart({ "ffprobe", "-hide_banner", "-i", path }, 1000, false)
        if subtype == "mp4" then
            local has_video = false
            for _, line in pairs(lines) do
                if line:find("Video") ~= nil then
                    has_video = true
                end
            end
            if not has_video then
                mediatype = "audio"
            end
        end
        return lines, ("vfiler-preview-%s.%s"):format(mediatype, subtype)
    end
    if mediatype == "image" then
        local _, lines = sync_jobstart({ "sips", "-g", "all", path }, 1000, false)
        return lines, "vfiler-preview-image." .. subtype
    end
    -- if subtype == "pdf" then
    --     return {}, "vfiler-preview-image." .. subtype
    -- end
    if subtype == "json" then
        return default_read_file_func(path)
    end
    if subtype == "zip" then
        local _, lines = sync_jobstart({ "unzip", "-l", path }, 1000, false)
        return lines, ""
    end
    if subtype == "gzip" then
        local exitcode, lines = sync_jobstart({ "tar", "tzf", path }, 1000, false)
        if exitcode == 0 then
            return lines, "tar"
        end

        local _, gunzip_lines = sync_jobstart({ "gunzip", "-l", path }, 1000, false)
        return gunzip_lines, ""
    end
    if subtype == "x-rar" then
        local _, lines = sync_jobstart({ "unrar", "ltabp", path }, 1000, true)
        return lines, ""
    end
    local _, lines = sync_jobstart({ "xxd", path }, 1000, false)
    return lines, ""
end

local function read_file_func(path, default_read_file_func)
    local file = vim.fn.shellescape(path)
    local maxtime = 6000
    local exitcode, lines = sync_jobstart({
        "ffprobe", "-v", "0", "-select_streams", "V:0",
        "-show_entries", "format=duration", "-of", "default=nw=1:nk=1",
        path,
    }, 1000, false)
    if exitcode == 0 then
        local time = tonumber(lines[1])
        if time ~= nil then
            maxtime = time
        end
    end
    return {
        "sh", "-c", ("for i in $(seq 0 300 %d); do ffmpeg -ss $i -i %s -r 1 -f gif -vf 'thumbnail=100,setpts=(PTS-STARTPTS)/10' -vframes 4 - 2>/dev/null | (viu -1 -b -a -x 0 -y 0 -); done")
        :format(maxtime, file),
    }, "terminal"
end

return read_preview_file
