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

local function send(path)
	print(path, config.host)
	--[[
	local f = io.open(path, "rb")
	local attr = lfs.attributes(path)
	local response = {}
	local source = ltn12.source.string(f:read(attr.size))
	local body,code,headers,status = http.request{
        url = "localhost:3000/upload",
        method = "POST",
		headers = {
			["Content-Type"] = "application/zip",
            ["Content-Length"] = tostring(attr.size)
		},
		source = ltn12.source.file(f),
		sink = ltn12.sink.table(response)
    }
	print(body,code,headers,status)
	if headers then for k,v in pairs(headers) do print(k,v) end end
	]]
	local curl = string.format("curl -F data=@%s %s", path, config.host)
	os.execute(curl)
end

function upload:sendToServer(builder, path)
	send(path)
end

function upload:zip(builder) 
    local ZipStream = ZipWriter.new()

	-- Sets builder's zip data
	builder.zipName = string.format("%s-%s.zip", config.projectName, builder.name)
    builder.zipPath = string.format("%s%s", config.buildPath, builder.zipName)
	
    print("Zipping to " .. builder.zipPath)
    ZipStream:open_stream(assert(io.open(builder.zipPath, 'w+b')), true)
    zipFiles(builder, ZipStream, nil)
    ZipStream:close()
    return zipPath
end

return upload