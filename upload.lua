local upload = {}

--- Used in the zip files write process. Returns a ZipWriter file desc and a sink for that files data.
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

--- Uploads build data and zip file to config.host using http request, curl and forms.
function upload:sendToServer(builder, path)
	print(path, config.host)
	-- cURL command to send a form of zip file to the host.
	-- I decided this way because luasocket.http doesnt work well
    local curl = string.format(
        "curl -H %s -F %s -F %s -F %s -F %s %s",
		"enctype=\"multipart/form-data\"",
		"data=@"     .. path,
		"projName="  .. config.projectName,
		"projVer="   .. config.projectVersion,
		"projPlat="  .. config.buildSettings[builder.name].target or builder.name,
        config.host)
	os.execute(curl)
		
	--local curl = "curl -F data=@%s %s"
end

--- Zips contents of a directory into a zip.
---
--- Requires a builder or build:build reference
---
--- Zip path is taken from builder.zipPath
function upload:zip(builder)
    local ZipStream = ZipWriter.new()
    print("Zipping to " .. builder.zipPath)
    ZipStream:open_stream(assert(io.open(builder.zipPath, 'w+b')), true)
    zipFiles(builder, ZipStream, nil)
    ZipStream:close()
end

return upload