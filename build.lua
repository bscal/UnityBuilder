local upload = require("upload")

local build = {}

build.name = ""
build.zipName = ""
build.zipPath = ""
build.path = ""
build.target = ""
build.hashStr = "0"
build.size = 0
build.buildHashes = {}

-- Handles the removal and creation of the temp project directory
local function handleTempDir(path)
    -- Get temp dirs attributes
    local dir = lfs.attributes(path)
    -- If exists
    if (dir ~= nil) then
        if (dir.mode == "directory") then -- If dir then delete dir
            lfs.rmdir(path)
        else -- If file for some reason delete fil
            os.remove(path)
        end
    end
    -- Make dir
    lfs.mkdir(path)
end

local function createTempProject(fromPath, toPath)
    for file in lfs.dir(fromPath) do
        if (not utils:isIgnoredFile(file)) then
            local srcPath = fromPath .. "/" .. file
            local destPath = toPath .. "/" .. file

            local attr = lfs.attributes(srcPath)

            if (attr.mode == "directory") then
                lfs.mkdir(destPath)
                createTempProject(srcPath, destPath)
            else
                local src = assert(io.open(srcPath, "rb"))
                local data = src:read("*a")
                src:close()
                local dest = assert(io.open(destPath, "wb"))
                dest:write(data)
                dest:close()
            end
        end
    end
end

local function moveResourcesFiles(path)
    for file in lfs.dir(path) do
        if (file ~= nil and file ~= "." and file ~= "..") then
            local newPath = path .. "/" .. file
            local attr = lfs.attributes(newPath)

            if (attr.mode == "directory") then
                moveResourcesFiles(newPath)
            else
                local src = assert(io.open(newPath, "rb"))
                local data = src:read("*a")
                src:close()
                local dest = assert(io.open(string.format("%s/%s/%s", config.buildPath, build.name, file), "wb"))
                dest:write(data)
                dest:close()
            end
        end
    end
end

function build:build(name, path)
    build.name = name
    build.path = path

    print(string.format("Building Unity project: %s for platform: %s \n  ProjectPath:  %s \n  BuildPath:    %s\n  UnityInstall: %s", config.projectName, name, config.projectPath, config.buildPath, config.unityPath))
--[[
	if (config.skip.hash)
		local hash = self:hash(path)

		if (hash == self.hashStr) then
		   return self.hashStr
		end
		self.hashStr = hash

		handleTempDir(config.tempPath)
	end
    ]]
    print("Running build command...")
    local cmd = string.format("%s -quit -batchmode -nographics -logFile stdout.log -projectPath %s -executeMethod BuildScript.%s", config.unityPath, config.tempPath, name)
    --os.execute(cmd)

    print(string.format("Creating temp project in %s", config.tempPath))
    --createTempProject(config.projectPath, config.tempPath)

    print("Moving resource files...")
    --moveResourcesFiles(lfs.currentdir() .. config.resourcePath)

    print("Zipping files...")
    --self.zipPath = upload:zip(self)
	
	self.zipName = string.format("%s-%s.zip", config.projectName, self.name)
    self.zipPath = string.format("%s%s", config.buildPath, self.zipName)
	
	print("Sending file to server")
    upload:sendToServer(self, self.zipPath)
end

local function readBytes(path)
    local f = io.open(path, "rb")
    if (f ~= nil) then
        local data = f:read("*a")
        f:close()
        return(data)
    end
end

function build:hash(path)
    local str = ""
    for file in lfs.dir(path) do
        if (not utils:isIgnoredFile(file)) then
            local newPath = path .. "/" .. file
            local attr = lfs.attributes(newPath)

            if (config.verbose) then print(file .. " = " .. attr.mode) end
            if (attr.mode == "directory") then
                str = str .. self:hash(newPath)
            else
                str = str .. md5.sum(readBytes(newPath) or "")
            end
        end
    end
    return md5.sum(str)
end

return build