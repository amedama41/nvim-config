---start job synchronously
---@param cmd table
---@param timeout_ms number
---@return integer
---@return table
local function sync_jobstart(cmd, timeout_ms)
    local obj = vim.system(cmd, {
        clear_env = true,
        detach = true,
        text = true,
        timeout = timeout_ms,
    }, nil):wait(timeout_ms)
    local text = (obj.stdout ~= "" and obj.stdout) or obj.stderr
    return obj.code, vim.split(text, "\n", { plain = true })
end

---return mediatype and subtype
---@param path string
---@return string
---@return string
local function get_filetype(path)
    local exitcode, lines = sync_jobstart({ "file", "-Ib", path }, 1000)
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
        local _, lines = sync_jobstart({ "ffprobe", "-hide_banner", "-i", path }, 1000)
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
        if mediatype ~= "audio" then
            mediatype = "video"
        end
        return lines, "vfiler-preview-" .. mediatype
    end
    if mediatype == "image" then
        local _, lines = sync_jobstart({ "sips", "-g", "all", path }, 1000)
        return lines, "vfiler-preview-image"
    end
    if subtype == "pdf" then
        return {}, "vfiler-preview-image"
    end
    if subtype == "json" then
        return default_read_file_func(path)
    end
    if subtype == "zip" then
        local _, lines = sync_jobstart({ "unzip", "-l", path }, 1000)
        return lines, ""
    end
    if subtype == "gzip" then
        local exitcode, lines = sync_jobstart({ "tar", "tzf", path }, 1000)
        if exitcode == 0 then
            return lines, "tar"
        end

        local _, gunzip_lines = sync_jobstart({ "gunzip", "-l", path }, 1000)
        return gunzip_lines, ""
    end
    if subtype == "x-rar" then
        local _, lines = sync_jobstart({ "unrar", "ltabp", path }, 1000)
        return lines, ""
    end
    local _, lines = sync_jobstart({ "xxd", path }, 1000)
    return lines, ""
end

local function read_file_func(path, default_read_file_func)
    local file = vim.fn.shellescape(path)
    local maxtime = 6000
    local exitcode, lines = sync_jobstart({
        "ffprobe", "-v", "0", "-select_streams", "V:0",
        "-show_entries", "format=duration", "-of", "default=nw=1:nk=1",
        path,
    }, 1000)
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
