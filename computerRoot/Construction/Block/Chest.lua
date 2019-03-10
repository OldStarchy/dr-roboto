Chest = Class(Block)
Chest.ClassName = 'Chest'

Chest.DOUBLE = 54
Chest.SINGLE = 27

--[[
	location: Position

	where the direction provided in Position will be the approach direction
	from the turtle to the block
]]
function Chest:constructor(location, isDoubleOrInventory)
	Block.constructor(self, location)

	if (isType(isDoubleOrInventory, 'boolean')) then
		self._inventory = ItemStore(isDoubleOrInventory and Chest.DOUBLE or Chest.SINGLE)
	else
		assertType(isDoubleOrInventory, ItemStore, 'isDoubleOrInventory must be true/false or an ItemStore', 2)

		self._inventory = isDoubleOrInventory
	end
end

function Chest:inventory()
	return self._inventory
end
