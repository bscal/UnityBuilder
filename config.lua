local config = {
    builds = {
        "Windows64",
        "Linux64"
    },

    buildSettings = {
        ["Windows64"] = {
            target = "StandaloneWindows-x64",
        },
        ["Linux64"] = {
            target = "StandaloneLinux-x64",
        }
    },

    -- Directories that are ignored for checking updates
    -- Right now these names are only checked by name. So paths will have no effect
    ignoredDirs = {
        ".",
        "..",
        ".git",
        ".vs",
        "builds",
        "bin",
        "obj",
        "Logs",
        "Library",
        "Temp",
    },
}

config.projectName = "Ballers"
config.projectVersion = "0.0.1"
config.unityPath = "F:/dev/2019.3.14f1/Editor/Unity.exe" -- Path to unity.exe
config.projectPath = "F:/dev/" .. config.projectName -- Path to unity project
config.tempPath = "F:/dev/" .. config.projectName .. "-temp" -- Unity temp project for building
config.buildPath = "F:/dev/" .. config.projectName .. "/builds/" -- Path to place built files in
config.resourcePath = "/resources" -- If you have files that need to be included that are not built
config.host = "127.0.0.1:3000/upload"

-- These are debug settings
config.verbose = false

-- Skips part of the build. true = will skip
config.skip = {
	hash = true,
	build = true,
	meta = true,
	zip = true,
	upload = false
}


return config