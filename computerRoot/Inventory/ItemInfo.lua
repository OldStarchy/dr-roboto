ItemInfo = Class()
ItemInfo.ClassName = 'ItemInfo'

function ItemInfo:constructor()
	self.itemDictionary = hardTable('item.dictionary')
end

function ItemInfo:getStackSize(item)
	return self.itemDictionary[item] or 64
end

function ItemInfo:setStackSize(item, size)
	self.itemDictionary[item] = size
end
