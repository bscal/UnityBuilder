local upload = require("upload")

local build = {}

build.name = ""
build.zipName = ""
build.zipPath = ""
build.buildPath = ""
build.hashStr = "0"
build.buildHashes = {}
build.meta = {}

local function createMetaFile()
    local f = assert(io.open(build.buildPath .. "/build.meta", "w"))

    for k,v in pairs(build.meta) do
        f:write(k .. "=" .. v)
    end
    f:close()
end

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
    build.buildPath = path

    print(string.format("Building Unity project: %s for platform: %s \n  ProjectPath:  %s \n  BuildPath:    %s\n  UnityInstall: %s", config.projectName, name, config.projectPath, config.buildPath, config.unityPath))

	-- Sets hashes for the build
	if (not config.skip.hash) then
		local hash = self:hash(path)

		if (hash == self.hashStr) then
		   return self.hashStr
		end
		self.hashStr = hash

		handleTempDir(config.tempPath)
	end

	if (not config.skip.build) then
		-- Creates a temp project to build because only 1 Unity project can be open at a time
		print(string.format("Creating temp project in %s", config.tempPath))
		createTempProject(config.projectPath, config.tempPath)
		
		-- Preforms a Unity build command
		print("Running build command...")
		local cmd = string.format("%s -quit -batchmode -nographics -logFile stdout.log -projectPath %s -executeMethod BuildScript.%s", config.unityPath, config.tempPath, name)
		os.execute(cmd)

		-- Moves over any resources files
		print("Moving resource files...")
		moveResourcesFiles(lfs.currentdir() .. config.resourcePath)
	end

	if (not config.skip.meta) then
		-- TODO possible add a meta data file to the build.
		build.meta.build = name
		build.meta.project = config.projectName
		build.meta.version = config.projectVersion
		build.meta.platform = config.buildSettings[self.name].target
		build.meta.hash = self.hashStr
		build.meta.date = socket.gettime() * 1000
		createMetaFile()
	end

	-- Sets zip varswd
	self.zipName = string.format("%s-%s.zip", config.projectName, self.name)
    self.zipPath = string.format("%s%s", config.buildPath, self.zipName)

	-- Zips the built project
	if (not config.skip.zip) then
		print("Zipping files...")
		upload:zip(self)
	end
	
	-- Uploads the project with cURL to the host
	if (not config.skip.upload) then
		print("Sending file to server")
		upload:sendToServer(self, self.zipPath)
	end
	
	print("Done build")
end

local function readBytes(path)
    local f = io.open(path, "rb")
    if (f ~= nil) then
        local data = f:read("*a")
        f:close()
        return(data)
    end
end

-- returns a 16 char md5 hash of the specified path. is recurrsive 
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