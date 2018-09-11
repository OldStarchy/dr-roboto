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
