# Testing without ComputerCraft

## Overview

Dr. Roboto is designed for the latest official release of ComputerCraft, as such, it runs on LUA 5.1.

## Windows Lua Install Instructions

Use the installers available online to install lua 5.1, and luarocks, then install lfs with

```
luarocks install luafilesystem
```

## Mac Lua Install Instructions

```
brew install lua51
brew install luarocks
luarocks --lua-dir=/usr/local/opt/lua@5.1 install luafilesystem
```

Depending on your set up you may need to configure tasks.json with the correct lua 5.1 path. You may also need to configure luafilesystem (lfs) so that lua can find the file.

## Running Code

The `startup` file found in the `computerRoot` directory can be run directly from your computer `lua computerRoot/startup`. Its important to note that the working directory should be the root of this project so that the polyfills are located correctly. There is a VSCode task setup already to do this.

A few of the ComputerCraft specific APIs have polyfills to provide compatibility with running on a native lua installation.

To see what ComputerCraft API's are available, look in the [\_polyfills](../_polyfills) directory.

If you'd like an interactive prompt similar to what you'd find in-game, there is a shell program located at [`programs/Shell.lua`](../computerRoot/programs/Shell.lua), so including the following line in your `mystartup.lua` will get you what you seek.

```lua
if (os.isPc()) then
    loadfile('programs/Shell.lua')()

    -- log.removeWriter(1) --optional
    -- loadfile('test.lua')()
end
```

After that you can run commands as you would through the Turtle's prompt.

```text
Dr. Roboto Shell

>lua
Interactive Lua prompt.
Call exit() to exit.
lua>go = include 'Go/_main'
lua>go:execute('udlr', true)
```

## Debugging

To run the code on your computer, you need to install `lfs`.

To use line-by-line debugging, install the Lua Debugger (recommended by this repo) and install `dkjson` and `luasocket`. `luasocket` may already be installed on your system.

I highly recommend using `luarocks` to install these dependencies.

Once this is all setup, hitting F5 (or whatever shortcut you've got setup) will launch LUA running [debug.lua](../debug.lua) and start debugging. The debugger will run the same as using the test task mentioned below, but will be somewhat slower due to the debugging hooks.
