local config = require("config")

for i = 1,#config.builds do
    local cmd = string.format("%s -quit -batchmode -logFile stdout.log -projectPath %s -executeMethod BuildScript.%s", config.unityPath, config.projectPath, config.builds[i])
    print(cmd)
    os.execute(cmd)
end
