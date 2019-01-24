# Navigation

## Mapping

A map is a set of Points of Interest (Blocks and Zones) used for navigating the turtles whilst trying to avoid breaking anything or getting stuck.

## API

### `Map()`

Creates a map object

### `:setProtected(x: int, y: int, z: int, protected: bool)`

Sets a block as protected (no entry) or unprotected. The pathfinding will not enter protected blocks when planning a path.

### `:findPath(start: Position, ed: Position): Position[]`

Tries to find a path from `start` to `ed`. If no path is found, `nil` is returned.

The pathfinding uses the A-Star pathfinding algorithm, taking into consideration the facing direction fo the robot.

If a path is found, it will return a list of `Position`s detailing the path

```LUA
m = Map()

local a = Position(0, 0, 0, Position.WEST)
local b = Position(0, 0, 2)

print('finding path from')
print(a)
print('to')
print(b)
print('')

m:setProtected(0, 0, 1, true)
m:setProtected(0, 1, 1, true)
m:setProtected(0, -1, 1, true)
m:setProtected(-1, 0, 0, true)
m:setProtected(1, 0, 0, true)
m:setProtected(0, 1, 0, true)
m:setProtected(0, -1, 0, true)
path = m:findPath(a, b)

if (path == nil) then
	print('path is nil')
else
	for i, v in ipairs(path) do
		print(i, v)
	end
end
```

```
finding path from
x: 0, y: 0, z: 0, f: W
to
x: 0, y: 0, z: 2, f: E

1 x: 0, y: 0, z: 0, f: W
2 x: 0, y: 0, z: 0, f: S
3 x: 0, y: 0, z: -1, f: S
4 x: 0, y: 1, z: -1, f: S
5 x: 0, y: 2, z: -1, f: S
6 x: 0, y: 2, z: 0, f: S
7 x: 0, y: 2, z: 1, f: S
8 x: 0, y: 2, z: 2, f: S
9 x: 0, y: 1, z: 2, f: S
10 x: 0, y: 0, z: 2, f: S
11 x: 0, y: 0, z: 2, f: E
```
