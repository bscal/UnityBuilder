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
        "Library"
    },

    unityPath = "F:\\dev\\2019.3.14f1\\Editor\\Unity.exe", -- Path to unity.exe
    projectPath = "F:\\dev\\Ballers", -- Path to unity project
    buildPath = "F:\\dev\\Ballers\\builds\\", -- Path to place built files in
    resourcePath = "\\resources" -- If you have files that need to be included that are not built
}

return config