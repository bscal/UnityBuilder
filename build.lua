local upload = require("upload")

local build = {}

build.name = ""
build.path = ""
build.target = ""
build.hashStr = "0"
build.buildHashes = {}

local function isIgnoredFile(str)
    for _, v in pairs(config.ignoredDirs) do
        if (v == str) then return true end
    end
    return false
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

    print(string.format("Building: %s Path: %s", name, path))

    local hash = self:hash(path)

    if (hash == self.hashStr) then
        return self.hashStr
    end
    self.hashStr = hash

    local cmd = string.format("%s -quit -batchmode -logFile stdout.log -projectPath %s -executeMethod BuildScript.%s", config.unityPath, config.projectPath, name)
    print(cmd)
    --os.execute(cmd)

    moveResourcesFiles(lfs.currentdir() .. config.resourcePath)
    upload:zip(self)
end

local function readBytes(path)
    local f = io.open(path, "rb")
    if (f ~= nil) then
        local data = f:read("*a")
        f:close()
        return(data)
    end
    f:close()
end

function build:hash(path)
    local str = ""
    for file in lfs.dir(path) do
        if (isIgnoredFile(file) ~= true) then
            local newPath = path .. "/" .. file
            local attr = lfs.attributes(newPath)

            if (attr.mode == "directory") then
                print(file .. " = dir")
                str = str .. self:hash(newPath)
            else
                print(file .. " = file")
                str = str .. md5.sum(readBytes(newPath))
            end
        end
    end
    return md5.sum(str)
end

return build