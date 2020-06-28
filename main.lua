lfs = require("lfs")
md5 = require("md5")
ltn12 = require("ltn12")
ZipWriter = require("ZipWriter")

config = require("config")
utils = require("utils")
build = require("build")
upload = require("upload")

local projectHash = ""

function sleep(s)
    local ntime = os.time() + s
    repeat until os.time() > ntime
end

function updateLoop()
    while (true) do
        print("checking for changes...")
        local hash = build:hash(config.projectPath) -- Hashes the project. You can skip files in config.ignoredDirs
        if (hash ~= projectHash) then
            projectHash = hash
            for i = 1,#config.builds do
                local res = build:build(config.builds[i], config.buildPath .. config.builds[i])
                if res == 1 then -- Only used this to debug stuff but left it in. res == 0 would mean ok.
                    print("errored")
                    return
                end
            end
        end
		sleep(1)
        print("Sleeping for 15 seconds. This is ideal time to interrupt the script.")
        sleep(15)
    end
end

-- commented out for debugging
updateLoop()