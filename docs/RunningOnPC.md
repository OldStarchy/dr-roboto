# Testing without ComputerCraft

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

Lua 5.1 is needed as this is what Lua version ComputerCraft will run within Minecraft.

A few of the ComputerCraft specific apis have polyfills to provide compatibility with running on a native lua installation. The VSCode test task can be used to run the Dr. Roboto's startup tests. Additionally, you can achieve a similar environment with the following

```lua
dofile 'bootstrap.lua'
include 'Core/_main'
```

After that you can run commands as you would through the Turtle's lua prompt.

```lua
go = include 'Go/_main'
go:execute('udlr', true)
```

The mock `turtle` API just prints out function calls and stack traces, so the above outputs the following:

```
called turtle.getFuelLevel(     nil     )
.\Navigation/Navigator.lua:73:
-
Go/MoveAction.lua:6:
Go/FunctionAction.lua:35:
Go/MoveAction.lua:40:
Go/Sequence.lua:26:
called turtle.up(       nil     )
.\Navigation/Navigator.lua:399:
-
.\Navigation/Navigator.lua:97:
-
Go/MoveAction.lua:6:
Go/FunctionAction.lua:35:
Go/MoveAction.lua:40:
called turtle.getFuelLevel(     nil     )
.\Navigation/Navigator.lua:73:
-
Go/MoveAction.lua:6:
Go/FunctionAction.lua:35:
Go/MoveAction.lua:40:
Go/Sequence.lua:26:
called turtle.down(     nil     )
.\Navigation/Navigator.lua:409:
-
.\Navigation/Navigator.lua:97:
-
Go/MoveAction.lua:6:
Go/FunctionAction.lua:35:
Go/MoveAction.lua:40:
called turtle.turnLeft( nil     )
.\Navigation/Navigator.lua:427:
.\Navigation/Navigator.lua:165:
-
Go/FunctionAction.lua:7:
Go/FunctionAction.lua:35:
Go/FunctionAction.lua:45:
called turtle.turnRight(        nil     )
.\Navigation/Navigator.lua:419:
.\Navigation/Navigator.lua:175:
-
Go/FunctionAction.lua:7:
Go/FunctionAction.lua:35:
Go/FunctionAction.lua:45:
```
