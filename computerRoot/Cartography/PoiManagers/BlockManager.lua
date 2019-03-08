-- Store and maintain the current important _blocks

BlockManager = Class()
BlockManager.ClassName = 'BlockManager'

--[[
	name: name of the item, 'chest', 'furnace', or block query that is used to select the item from inventory
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function BlockManager:constructor(map)
	self._map = assertParameter(map, 'map', Map)
	self._blocks = {}

	self.ev = EventManager()
end

function BlockManager.Deserialize(tbl)
	local obj = BlockManager(Map.Instance)

	for _, block in ipairs(tbl) do
		obj:add(block)
	end

	-- print(tableToString(tbl))
	return obj
end

function BlockManager:serialize()
	return self._blocks
end

function BlockManager:add(block)
	assertType(block, Block, 'Attempt to add a non block to a block map', 2)

	if (self:findBlockByLocation(block.location) ~= nil) then
		return false
	end

	table.insert(self._blocks, block)

	self._map:setProtected(block.location, true)

	self.ev:trigger('state_changed')

	return true
end

function BlockManager:remove(block)
	assertType(block, Block, 'Attempt to remove a non block to a block map', 2)

	local blockInMap, key = self:findBlockByLocation(block.location)
	if (blockInMap == nil) then
		return false
	end

	table.remove(self._blocks, key)

	self.ev:trigger('state_changed')

	return true
end

function BlockManager:findBlockByLocation(atPosition)
	assertType(atPosition, Position, 'Attempted to find a block by a location that wasnt a position object', 2)

	local position = atPosition

	for k, block in ipairs(self._blocks) do
		if (block.location:posEquals(position)) then
			return block, k
		end
	end

	return nil
end

-- returns the closest block of that type to the provided location
-- block type should be the class name of the block
function BlockManager:findNearest(toLocation)
	assertType(toLocation, Position, 'Attempted to find a block by a location that wasnt a position object', 2)

	local other = toLocation

	local currentSmallest = nil
	local smallestDistance = 99999999

	for _, block in ipairs(self._blocks) do
		local distance = block.location:distanceTo(other)
		if distance < smallestDistance then
			smallestDistance = distance
			currentSmallest = block
		end
	end

	return currentSmallest
end
