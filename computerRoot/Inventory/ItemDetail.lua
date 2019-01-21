ItemDetail = Class()
ItemDetail.ClassName = 'ItemDetail'

function ItemDetail:constructor(name, metadata)
	self.name = name
	self.metadata = metadata
end

function ItemDetail:conversionConstructor()
	if (self.damage ~= nil) then
		self.metadata = self.damage
	elseif (self.metadata ~= nil) then
		self.metadata = self.metadata
	end
end

function ItemDetail.FromId(id)
	local parts = stringutil.split(id, ':')

	if (#parts == 1) then
		return ItemDetail('minecraft:' .. id, 0)
	elseif (#parts == 2) then
		if (tonumber(parts[2]) == nil) then
			return ItemDetail(id, 0)
		else
			return ItemDetail('minecraft:' .. parts[1], tonumber(parts[2]))
		end
	elseif (#parts == 3) then
		if (tonumber(parts[3]) == nil) then
			return ItemDetail(id, 0)
		else
			return ItemDetail(parts[1] .. ':' .. parts[2], tonumber(parts[3]))
		end
	else
		error('invalid format for item id "' .. id .. '"', 2)
	end
end

function ItemDetail:toString()
	return textutils.serialize(self)
end

function ItemDetail:matches(selector)
	if (selector == '*') then
		return true
	end

	local name = self.name .. ':' .. self.metadata

	local subSelectors = {}
	for subSelector in selector:gmatch('[^,]*') do
		local colons = select(2, subSelector:gsub(':', ''))
		if (colons == 0) then
			subSelector = '*:' .. subSelector .. ':*'
		elseif (colons == 1) then
			subSelector = '*:' .. subSelector
		end
		subSelector = string.gsub(subSelector, '([%(%)%.%%%+%-%?%[%^%$%]])', '%%%1')
		subSelector = string.gsub(subSelector, '%*', '[^:]*')
		table.insert(subSelectors, subSelector)
	end

	for _, subSelector in pairs(subSelectors) do
		if (name:match(subSelector)) then
			return true
		end
	end
	return false
end

function ItemDetail:getId()
	return self.name .. ':' .. self.metadata
end

function ItemDetail:isLiquid()
	return self:matches('lava') or self:matches('water')
end
