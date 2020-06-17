local lfs = require("lfs")
md5 = require("md5")
local http = require("socket.http")
local ltn12 = require("ltn12")
ZipWriter = require("ZipWriter")

config = require("config")
utils = require("utils")
local build = require("build")
local upload = require("upload")

local projectHash = ""

function sleep(s)
    local ntime = os.time() + s
    repeat until os.time() > ntime
end

function updateLoop()
    while (true) do
        print("checking for changes...")
        local hash = build:hash(config.projectPath)
        if (hash ~= projectHash) then
            projectHash = hash
            for i = 1,#config.builds do
                local res = build:build(config.builds[i], config.buildPath .. config.builds[i])
                if res == 1 then
                    print("errored")
                    return
                end
            end
        end
        print("Sleeping for 15 seconds. This is ideal time to interrupt the script.")
        sleep(15)
    end
end

-- commented out for debugging
updateLoop()

function init()
    for i = 1,#config.builds do
        --local cmd = string.format("%s -quit -batchmode -logFile stdout.log -projectPath %s -executeMethod BuildScript.%s", config.unityPath, config.projectPath, config.builds[i])
        --print(cmd)
        --os.execute(cmd)
        --print(build:hash("F:/dev/Ballers/builds/Windows64/"))
        --build:build(config.builds[i], config.buildPath .. config.builds[i])
    end
end

--init()