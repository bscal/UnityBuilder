local upload = {}

local function makeReader(file, attr)
    local f = assert(io.open(file, "rb"))
    local desc = {
        istext   = false,
        isfile   = true,
        isdir    = false,
        mtime    = attr.modification, -- lfs.attributes('modification') 
    }
    return desc, desc.isfile and function()
        local chunk = f:read(attr.size)
        if chunk then return chunk end
        f:close()
    end
end

local function zipFiles(builder, ZipStream, localPath)
    local curPath = builder.path
    if (localPath ~= nil) then curPath = curPath .. "\\" .. localPath end

    for file in lfs.dir(curPath) do
        if (file ~= nil and file ~= "." and file ~= "..") then
            local filePath
            if (localPath ~= nil) then filePath = localPath .. "\\" .. file else filePath = file end
            local newPath = curPath .. "\\" .. file
            if (config.verbose) then print("zipping", curPath, filePath) end
            local attr = lfs.attributes(newPath)

            if (attr.mode == "directory") then
                zipFiles(builder, ZipStream, filePath)
            else
                ZipStream:write(filePath, makeReader(newPath, attr))
            end

        end
    end
end

local function sendToServer()
end

function upload:zip(builder) 
    local ZipStream = ZipWriter.new()

    local filename = string.format("%s%s-%s.zip", config.buildPath, config.projectName, builder.name)
    print("Zipping to " .. filename)
    ZipStream:open_stream(assert(io.open(filename, 'w+b')), true)
    zipFiles(builder, ZipStream, nil)
    ZipStream:close()
end

function upload:send(path)
    http.request{
        url = config.host,
        method = "POST",
        source = ltn12.source.file(io.open(path, "rb")),
        sink = ltn12.sink.file(io.stdout),
    }
end

return upload