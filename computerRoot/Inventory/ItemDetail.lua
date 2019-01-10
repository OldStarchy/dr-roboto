ItemDetail = Class()
ItemDetail.ClassName = 'ItemDetail'

function ItemDetail:constructor()
	error("Can't construct items manually", 3)
end

function ItemDetail:conversionConstructor()
	if (self:getType() == ItemDetail) then
		error('Use either ItemStackDetail or ItemDetail', 3)
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

function ItemDetail:isLiquid()
	return self:matches('lava') or self:matches('water')
end
