ChestManager = Class()
ChestManager.ClassName = 'ChestManager'

function ChestManager:constructor()
	self.ev = EventManager()

	--[[
		Array<{
			location: Position,
			chest: ItemStore
		}>
	]]
	self.chestLocations = {}
end

function ChestManager.Deserialize(tbl)
	local obj = ChestManager()

	obj.chestLocations = tbl
end

function ChestManager:serialize()
	return self.chestLocations
end

function ChestManager:expandStorage()
	local location = self:_getNextStorageLocation()

	--Todo: don't use the chest reserved used for crafting

	if (inv:getFreeItemCount('chest') < 1) then
		error('Need a chest to expand storage', 2)
	end

	nav:goTo(location)

	inv:pushSelection('chest')
	turtle.place()
	inv:popSelection()

	local chest = Chest()
end

--[[
	Find where to put the next chest
]]
function ChestManager:_getNextStorageLocation()
	--TODO
end

function ChestManager:itemCount(selector)
	selector = assertType(coalesce(selector, '*'), 'string')

	local total = 0

	for _, location in ipairs(self.chestLocations) do
		total = total + location.chest:itemCount(selector)
	end

	return total
end
