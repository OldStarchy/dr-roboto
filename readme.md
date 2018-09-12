# Dr. Roboto

> “Don't blame you," said Marvin and counted five hundred and ninety-seven thousand million sheep before falling asleep again a second later.”

― Douglas Adams, The Hitchhiker's Guide to the Galaxy

## Why?

For fun and learning.

## What?

A self replicating turtle for ComputerCraft

## Code Conventions

This project has a Class object which implements some basics of a Class based OO language, but its relatively simple. In order to assist with reading and understanding code there's a couple of conventions for development.

```lua

-- Class creation first
-- One class per file is idea.
-- Most classes won't be local
Robot = Class()

-- Static Scope: CamelCase

-- Methods (index with '.')
function Robot.GetFactory(name)
	local index = 0
	return function()
		index = index + 1
		return Robot.new(name .. ' ' .. index)
	end
end

-- Object scope: pascalCase

-- Default values

-- Constructor first (index with ':')
function Robot:constructor(name)
	-- Index statics with '.'
	-- 'private' variables start with _ and are pascalCase
	self._fuel = 0

	-- Use paretheses around if statements
	-- name is part of the 'public' api as it doesn't start with an _
	if (type(name) == 'string') then
		self.name = name
	else
		self.name = 'Unnamed Robot' -- Single quotes for strings
	end

	-- Index object scope methods with ':'
	self:_printCreationMethod()
end

-- Other object functions
function Robot:_printCreationMethod()
	print('I am', self.name, 'feel my wrath')
end

function Robot:refuel()
	self._fuel = 100
end


FastRobot = Class(Robot)

function FastRobot:constructor(name)
	self._speed = 'so fast'

	-- Explicitly call parents constructor if you overwrite it (with a '.')
	Robot.constructor(self, name)
end

function FastRobot:goFast()
	if (self.fuel > 10) then
		print('Going fast')
		self.fuel = self.fuel - 10
	else
		print('Not enough fuel to go fast')
	end
end

local bobBotFactory = Robot.GetFactory('Bob')

local bob1 = bobBotFactory()
--> I am Bob 1 feel my wrath
local bob2 = bobBotFactory()
--> I am Bob 2 feel my wrath

local fastBob = FastRobot.new('Fast Bob')
--> I am Fast Bob feel my wrath

fastBob:goFast()
--> Not enough fuel to go fast

-- Possible, but bad don't do this
-- fastBob._fuel = 100

-- Use the public api
fastBob:refuel()

fastBob:goFast()
--> Going fast
```


## Testing without ComputerCraft

A few of the ComputerCraft specific apis have polyfills to provide compatibility with running on a native lua installation. The VSCode test task can be used to run the Dr. Robotos startup tests. Additionally, you can achieve a similar environment with the following

```lua
dofile 'bootstrap.lua'
require 'Core'
```

After that you can run commands as you would through the Turtle's lua prompt.

```lua
go = require 'Go/_main'
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
