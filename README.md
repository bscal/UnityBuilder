# UnityBuilder
A lua 5.1 program that automatically builds and uploads unity projects

Currently a work in progress. And is not fully functional

Built with Unity2019, lua5.1 and luadist on Cygwin.

*TODO* Will eventually add a webserver to host these builds and possible automatically deploy or atleast set them up

## Getting Started
1. Clone the repo `https://github.com/bscal/UnityBuilder.git`
2. You will need to place BuildScript.cs into your Unity project somewhere in Assets/Editor/ directory
3. Build the needed lua dependencies (See dependencies)
4. Edit config.lua to desired settings
5. Run command `lua main.lua` or `bin/lua main.lua` if using Cygwin luadist install

It will not on 15sec intervals check your projects directory for changes. If changes detected<br>
then program will `build unity project -> move resource files -> zip files -> upload *TODO*`

## Dependencies
These were built using luadist.

Here is the full list of modules needed. If using luadist then you only need:<br>
`lua-5.1 ZipWriter luafilesystem luasocket md5`<br>
others will be installed as dependencies by luadist. The C compiler I used was GCC from Cygwin installer.

### Installed modules:
* ZipWriter-0.1.2       (Cygwin-x86)
* bit32-5.2.0alpha      (Cygwin-x86)
* lua-5.1.5     (Cygwin-x86)
* luafilesystem-1.6.2   (Cygwin-x86)
* luasocket-3.0-rc1     (Cygwin-x86)
* lzlib-0.4.2   (Cygwin-x86)
* md5-1.2       (Cygwin-x86)
* struct-1.4    (Cygwin-x86)
* zlib-1.2.6    (Cygwin-x86)

## Configuration
Most configuring will be done in config.lua

```
    builds - array of platforms to build
        Current platforms:
        - Windows64
        - Linux64

    buildSettings - Additional settings. Does nothing

    ignoredDirs - array of names to ignore checking for changes. Does not support full paths only names

    unityPath - Path to Unity.exe
    projectPath - Path to unity projects root
    buildPath - Path to projects build directories
    resourcePath - Path to resources folder. Root is UnityBuilder's current working directory.
```

Use the UnityBuilder/resources directory to move any files to the built directory<br>
that would not be generated from Unity's build. ie. SteamWorks steam_appid.txt<br>
File paths are not preserved.

BuildSettings.cs or the command in build.lua could be edited if you need further build settings.