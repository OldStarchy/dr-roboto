ItemStackDetail = Class(ItemDetail)
ItemStackDetail.ClassName = 'ItemStackDetail'

--[[
	name
	damage
	metadata
	count
]]
function ItemStackDetail:constructor(name, metadata, count)
	self.name = assertType(name, 'string')
	self.metadata = assertType(coalesce(metadata, 0), 'int')
	self.damage = self.metadata
	self.count = assertType(coalesce(count, 1), 'int')
end

function ItemStackDetail:conversionConstructor()
	assertType(self.name, 'string')
	assertType(self.damage, 'int')
	assertType(self.count, 'int')

	self.metadata = self.damage
end
