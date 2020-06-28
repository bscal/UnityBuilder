# UnityBuilder
A lua 5.1 program that automatically builds and uploads unity projects

Currently a work in progress. And is not fully functional or fully tested or fully anything.

Built and tested with Unity2019, lua 5.1. Uses Luadist and LuaRocks as package managers.

Has a built in nodejs express webserver for hosting files. Right now you can upload files to route /upload
but does not have any further functions.

You will need curl installed because the way files are uploaded are using a curl command. It also includes other metadata fields in the command which are needed to store the file properly.

Right now uploaded files are stored in `./uploads/(ProjectName)/(ProjectPlatform)/(ProjectName)-(ProjectVersion)-(DuplicateVersion).zip`

BuildScript.cs is not fully finished yet and have yet to decide on how to fully implement everything with it.

## Getting Started
1. Clone the repo `https://github.com/bscal/UnityBuilder.git`
2. You will need to place BuildScript.cs into your Unity project somewhere in Assets/Editor/ directory
3. Have curl installed
4. Have lua installed and the needed lua modules (See dependencies)
5. Have nodejs installed and initialize it
6. Edit config.lua to desired settings if needed
7. Make sure the server is up `node server.js` and address is configured in config.lua (Uses port 3000)
8. Run command `lua main.lua` or however you run your lua.

It will run on a 15sec interval checking your project directory for changes. If a change is detected then your project will be built and uploaded to your server.

## Dependencies
This is originally developed on Windows using Luadist on Cygwin. So I still believe all the dependencies can be
gotten with it. However I have changed how lua is setup on my PC and do not use Cygwin. I use a combination of Luadist, LuaRocks to manage dependencies and Lua version 5.1.

You must have curl installed.

### Installed Lua modules:
* ZipWriter
* luafilesystem
* luasocket (for ltn12)
* md5

If you use a lua package manager it should install the above module's dependencies. Which I recommend.

### Installed nodejs modules:
* express
* formidable

## Configuration
Most configuring will be done in config.lua

```
    builds - array of platforms to build
        Current platforms:
        "Windows64"
        "Linux64"

    buildSettings - Additional settings. If specified the target will be used in the uploaded zip's path. Falls back to build name.
        ["Windows64"] = {
            target = "StandaloneWindows-x64", 
        },

    ignoredDirs - array of names to ignore checking for changes. Does not support full paths only names

    projectName
    projectVersion
    unityPath - Path to Unity.exe
    projectPath - Path to unity projects root
    tempPath - Unity temp project for building
    buildPath - Path to projects build directories
    resourcePath - Path to resources folder. Root is UnityBuilder's current working directory.
    host - Host address to upload too. Right now only port 3000 and route /upload works

    verbose - print debug info
    skip - array of build steps that can be toggled to skip
```

Use the UnityBuilder/resources directory to move any files to the built directory<br>
that would not be generated from Unity's build. ie. SteamWorks steam_appid.txt<br>
File paths are not preserved.

BuildSettings.cs or the command in build.lua could be edited if you need further build settings.

curl command in upload:sendToServer function can be edited also. I would not removed anything