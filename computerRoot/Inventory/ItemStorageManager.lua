ItemStorageManager = Class()
ItemStorageManager.ClassName = 'ItemStorageManager'

function ItemStorageManager:constructor()
	self.ev = EventManager()

	self.storageLocations = {}
end

function ItemStorageManager:expandStorage()
	local location = self:_getNextStorageLocation()

	nav:goTo(location)
end

ItemStorageManager.itemCount = function(item)
	-- Check storage chests
	return 0
end
