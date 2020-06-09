local config = require("config")
local lfs = require("lfs")


function hash(path)
    for file in lfs.dir(path) do
        if (file ~= nil and file ~= "." and file ~= "..") then
            local attr = lfs.attributes(path .. "/" .. file)

            if (attr.mode == "directory") then
                print(file .. " = dir")
            else
                print(file .. " = file")
            end
        end
    end
end
for i = 1,#config.builds do
    local cmd = string.format("%s -quit -batchmode -logFile stdout.log -projectPath %s -executeMethod BuildScript.%s", config.unityPath, config.projectPath, config.builds[i])
    print(cmd)
    --os.execute(cmd)
    hash("F:/dev/Ballers/builds/Windows64/")
end
