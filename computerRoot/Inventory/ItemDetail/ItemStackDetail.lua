ItemStackDetail = Class(ItemDetail)
ItemStackDetail.ClassName = 'ItemStackDetail'

--[[
	name
	damage
	metadata
	count
]]
function ItemStackDetail:constructor(name, metadata, count)
	ItemDetail.constructor(self, name, metadata)
	self.damage = self.metadata
	self.count = assertType(coalesce(count, 1), 'int')
end

function ItemStackDetail:conversionConstructor()
	ItemStackDetail.constructor(self, self.name, self.damage, self.count)
end

function ItemStackDetail:serialize()
	local tbl = ItemDetail.serialize(self)
	tbl.count = self.count

	return tbl
end

function ItemStackDetail.Deserialize(tbl)
	return ItemStackDetail(tbl.name, tbl.metadata, tbl.count)
end
