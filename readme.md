# Dr. Roboto

> “Don't blame you," said Marvin and counted five hundred and ninety-seven thousand million sheep before falling asleep again a second later.”

― Douglas Adams, The Hitchhiker's Guide to the Galaxy

## Why?

For fun and learning.

## What?

A self replicating turtle for ComputerCraft

## Docs

The docs are a work in progress, but go ahead and have a look in the docs folder, and raise an issue if you need some documentation that doesn't exist yet.

## Code Conventions

Before you start you should at least familiarize yourself with Lua's syntactic sugar, but for a quick reminder:

```lua
local obj {
    name = 'bob'
}

-- The following three function definitions are equivalent
obj.method = function(self, a, b, c)
    print(self.name, a, b, c)
end

-- A nicer looking version of the above
function obj.method(self, a, b, c)
    print(self.name, a, b, c)
end

-- Notice that when using a colon ":" the "self" parameter is included implicitly
function obj:method(a, b, c)
    print(self.name, a, b, c)
end


-- similarly when calling methods the following two are (practically) equivalent
obj.method(obj, 1, 2, 3)
--> bob 1   2   3

obj:method(1, 2, 3)
--> bob 1   2   3

-- So, the convention is:
-- * for object methods, use ":"
-- * for static methods and all variables, use "."

-- The difference between the two is subtle, and shouldn't affect anything in most cases, but here it is anyway

-- "obj" gets evaluated twice
obj.method(obj, 1, 2, 3)

-- "obj" gets evaluated once
obj:method(1, 2, 3)



-- A better example:
local count = 0
local obj2 = {
    name = 'bob'
}
function obj:printName()
    print(self.name)
end

function getObj()
    count = count + 1
    print(count, 'calls')
    return obj2
end

getObj().printName(getObj())
--> 1   calls
--> 2   calls
--> bob

count = 0
getObj():printName()
--> 1   calls
--> bob
```

This project has a Class object which implements some basics of a Class based OO language, but its relatively simple. In order to assist with reading and understanding code there's a couple of conventions for development.

```lua
-- Create classes by calling Class()
Animal = Class()
Animal.ClassName = 'Animal'

-- Class variables are defined on the class itself
-- They should start with a capital letter to differentiate them from object variables
-- They should also be documented (if their meaning isn't 100% obvious)

--[[
    The most recently crated animal since the last call to Reset, or nil
]]
Animal.MostRecentAnimal = nil

-- Variables that are intended as private (ie. not part of the 'public api') should start with an underscore
-- You shouldn't use these directly outside of the file that defines the class.
-- Documentation is less important but still recommended for larger classes

--[[
    The total number of animals created
]]
Animal._AnimalCount = 0


--[[
    returns: The total number of animals created since the last call to reset
]]
function Animal.GetAnimalCount()
    return Animal._AnimalCount
end

function Animal.ResetStatistics()
    Animal._AnimalCount = 0
    Animal.MostRecentAnimal = nil
end

-- Default object variables are declared here. Even if they are nil its good to declare them so code readers can learn about them

--[[
    _sound: string What sound does this animal make. Must be overridden in child classes
]]
Animal._sound = nil

--[[
    _type: string A human readable name for this type of animal. Can be overridden in child classes
]]
Animal._type = 'animal'

-- If you want, you can define a constructor
function Animal:constructor(name)
    -- Object variables are defined here
    self._name = name

    Animal.MostRecentAnimal = self
    Animal._AnimalCount = Animal._AnimalCount + 1
end

-- You can override the tostring method like so
function Animal:toString()
    -- and, while inside this method, you can use tostring(self) to call the native tostring method
    return 'A ' .. self._type .. ' named "' .. self._name .. '" (' .. tostring(self) .. ')'
end

-- If you don't override toString, it will use the default, which will return something like 'class: 00AC9840' (similar to the native version which returns 'table: 00AC9840')

function Animal:speak()
    print(self._name .. ' the ' .. self._type .. ' says ' .. self._sound)
end


-- Cat inherits from Animal
Cat = Class(Animal)
Cat.ClassName = 'Cat'

-- Remember comments make things easier to understand. The average programmer spends 10 times more time reading code then they do writing. (https://www.goodreads.com/quotes/835238-indeed-the-ratio-of-time-spent-reading-versus-writing-is)
--[[
    overrides: Animal._sound/_type
]]
Cat._sound = 'nyan'
Cat._type = 'cat'

-- The default constructor just calls the parent constructor

-- To instantiate an object, call the class itself
local scratch = Cat('Scratch')
scratch:speak()
--> Scratch the cat says nyan

Dog = Class(Animal)
Dog.ClassName = 'Dog'

function Dog:growl()
    print('grrrr')
end

print(Dog('Steevo'))
--> A animal named Steevo

print(Animal.GetAnimalCount())
--> 2


--Some extra stuff

print(scratch:getType() == Cat)
--> true

print(scratch:getType() == Animal)
--> false

print(scratch:isType(Cat))
--> true

print(scratch:isType(Animal))
--> true
```

The old example code I'm leaving in this readme because why not

```lua
-- Class creation first
-- One class per file is idea.
-- Most classes won't be local
Robot = Class()
Robot.ClassName = 'Robot'

-- Static Scope: CamelCase

-- Methods (index with '.')
function Robot.GetFactory(name)
	local index = 0
	return function()
		index = index + 1
		return Robot(name .. ' ' .. index)
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
FastRobot.ClassName = 'FastRobot'

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

local fastBob = FastRobot('Fast Bob')
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

# Mac Lua Install Instructions

```
brew install lua51
brew install luarocks
luarocks --lua-dir=/usr/local/opt/lua@5.1 install luafilesystem
```

Depending on your set up you may need to configure tasks.json with the correct lua 5.1 path. You may also need to configure luafilesystem (lfs) so that lua can find the file.

#Windows Lua Install Instructions
