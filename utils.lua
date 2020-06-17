local utils = {}

function utils:isIgnoredFile(str)
    for _, v in pairs(config.ignoredDirs) do
        if (v == str) then return true end
    end
    return false
end

function utils:cmdCapture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

return utils