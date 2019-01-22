-- Store and maintain the current important _blocks

BlockMap = Class()
BlockMap.ClassName = 'BlockMap'

--[[
	name: name of the item, 'chest', 'furnace', or block query that is used to select the item from inventory
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function BlockMap:constructor(filename)
	self._blocks = {}

	if (filename ~= nil) then
		assertType(filename, 'string')
		self._saveToFilename = filename
	end
end

function BlockMap.Deserialize(data)
	local map = BlockMap()
	for blockType, _ in ipairs(data) do
		for _, blockData in ipairs(data[key]) do
			block = _G[blockType].convertToInstance(blockData)
			block.location = Position.convertToInstance(block.location)
			block.interfaceLocation = Position.convertToInstance(block.interfaceLocation)
			-- print(block.location:toString())

			local blockList = map._blocks[blockType]
			if (blockList == nil) then
				map._blocks[blockType] = {block}
			else
				table.insert(blockList, block)
			end
		end
	end

	-- print(tableToString(data))
	return map
end

function BlockMap:saveToFile(filename)
	assertType(filename, 'string')
	print('saving to', filename)
	fs.writeTableToFile(filename, self._blocks)
end

function BlockMap.LoadFromFile(filename, autoSave)
	assertType(filename, 'string')
	local map

	if (fs.exists(filename)) then
		local data = fs.readTableFromFile(filename)

		map = BlockMap.Deserialize(data)
	else
		map = BlockMap()
	end

	if (autoSave) then
		map._saveToFilename = filename
	end

	return map
end

function BlockMap:add(block)
	assertType(block, Block, 'Attempt to add a non block to a block map', 2)

	local blockType = block.ClassName

	if (self:findBlockByLocation(blockType, block.location) ~= nil) then
		return false
	end

	local blockList = self._blocks[blockType]
	if (blockList == nil) then
		self._blocks[blockType] = {block}
	else
		table.insert(blockList, block)
	end

	if (self._saveToFilename ~= nil) then
		self:saveToFile(self._saveToFilename)
	end

	return true
end

function BlockMap:remove(block)
	assertType(block, Block, 'Attempt to remove a non block to a block map', 2)

	local blockType = block.ClassName

	local blockInMap, key = self:findBlockByLocation(blockType, block.location)
	if (blockInMap == nil) then
		return false
	end

	table.remove(self._blocks[blockType], key)

	if (self._saveToFilename ~= nil) then
		self:saveToFile(self._saveToFilename)
	end

	return true
end

function BlockMap:findBlockByLocation(blockType, atPosition)
	assertType(atPosition, Position, 'Attempted to find a block by a location that wasnt a position object', 2)
	assertType(blockType, 'string', 'Attempted to find a block by a block type that wasnt a string object', 2)

	local position = atPosition
	local blocksOfType = self._blocks[blockType]
	if (blocksOfType == nil) then
		return nil
	end

	for k, block in ipairs(blocksOfType) do
		if (block.location:posEquals(position)) then
			return block, k
		end
	end

	return nil
end

-- returns the closest block of that type to the provided location
-- block type should be the class name of the block
function BlockMap:findNearest(blockType, toLocation)
	assertType(toLocation, Position, 'Attempted to find a block by a location that wasnt a position object', 2)
	assertType(blockType, 'string', 'Attempted to find a block by a block type that wasnt a string object', 2)

	local other = toLocation

	local currentSmallest = nil
	local smallestDistance = 99999999

	if (self._blocks[blockType] == nil) then
		return nil
	end

	for _, block in ipairs(self._blocks[blockType]) do
		local distance = block.location:distanceTo(other)
		if distance < smallestDistance then
			smallestDistance = distance
			currentSmallest = block
		end
	end

	return currentSmallest
end
