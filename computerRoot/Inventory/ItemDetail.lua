ItemDetail = Class()
ItemDetail.ClassName = 'ItemDetail'

function ItemDetail:constructor(name, metadata)
	assertType(name, 'string')
	metadata = assertType(coalesce(metadata, 0), 'int')

	local colons = select(2, name:gsub(':', ''))
	if (colons == 0) then
		name = 'minecraft:' .. name
	end
	self.name = name:lower()
	self.metadata = metadata
end

function ItemDetail:serialize()
	return {
		name = self.name,
		metadata = self.metadata
	}
end

function ItemDetail.Deserialize(tbl)
	return ItemDetail(tbl.name, tbl.metadata)
end

function ItemDetail:conversionConstructor()
	if (self.damage ~= nil) then
		self.metadata = self.damage
	elseif (self.metadata ~= nil) then
		self.metadata = self.metadata
	end
end

function ItemDetail.FromId(id)
	local itemId = id:lower()
	local parts = stringutil.split(itemId, ':')

	if (#parts == 1) then
		return ItemDetail('minecraft:' .. itemId, 0)
	elseif (#parts == 2) then
		if (tonumber(parts[2]) == nil) then
			return ItemDetail(itemId, 0)
		else
			return ItemDetail('minecraft:' .. parts[1], tonumber(parts[2]))
		end
	elseif (#parts == 3) then
		if (tonumber(parts[3]) == nil) then
			return ItemDetail(itemId, 0)
		else
			return ItemDetail(parts[1] .. ':' .. parts[2], tonumber(parts[3]))
		end
	else
		error('invalid format for item id "' .. itemId .. '"', 2)
	end
end

function ItemDetail:toString()
	return serialize(self)
end

function ItemDetail.NormalizeId(id)
	local parts = stringutil.split(id, ':')
	if (#parts == 1) then
		id = '*:' .. id .. ':*'
	elseif (#parts == 2) then
		if (tonumber(parts[2]) == nil and parts[2] ~= '*') then
			id = id .. ':*'
		else
			id = '*:' .. id
		end
	end

	return id
end

function ItemDetail:matches(selector)
	assertType(selector, 'string')

	if (selector == '*') then
		return true
	end

	local subSelectors = {}

	for subSelector in selector:lower():gmatch('[^,]*') do
		if (subSelector ~= '') then
			subSelector = ItemDetail.NormalizeId(subSelector)

			subSelector = string.gsub(subSelector, '([%(%)%.%%%+%-%?%[%^%$%]])', '%%%1')
			subSelector = string.gsub(subSelector, '%*', '[^:]*')
			table.insert(subSelectors, subSelector)
		end
	end

	local name = self:getId()
	for _, subSelector in pairs(subSelectors) do
		if (name:match(subSelector)) then
			return true
		end
	end
	return false
end

function ItemDetail:getId()
	return ItemDetail.NormalizeId(self.name .. ':' .. self.metadata)
end

function ItemDetail:isLiquid()
	return self:matches('lava') or self:matches('water')
end

includeAll 'Inventory/ItemDetail'
