local utils = {}

--- Checks inputed string parameter if equals a config.ignoredDir value
--- Usefully if you would not want to copy a non needed file.
function utils:isIgnoredFile(str)
    for _, v in pairs(config.ignoredDirs) do
        if (v == str) then return true end
    end
    return false
end

--- Function to print output of a io.popen command.
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