TagManager = Class()
TagManager.ClassName = 'TagManager'

function TagManager:constructor(map)
	self._map = assertParameter(map, 'map', Map)

	--[[
		Dictionary<string, Array<Position>>
	]]
	self._tags = {}
end

function TagManager:getPosition(tag)
	assertParameter(tag, 'tag', 'string')

	return cloneTable(self._tags[tag])
end

function TagManager:clearTags(pos)
	assertParameter(pos, 'pos', Position)

	local oldTags = self._map:setData(pos, 'tags', nil)

	if (oldTags == nil) then
		return
	end

	for tag, _ in pairs(oldTags) do
		local tags = self._tags[tag]

		if (tags ~= nil) then
			for i = #tags, 1, -1 do
				if (tags[i] == pos) then
					table.remove(tags, i)
				end
			end
		end
	end

	self.ev:trigger('state_changed')
end

function TagManager:addTag(pos, tag)
	assertParameter(pos, 'pos', Position)
	assertParameter(tag, 'tag', 'string')

	local tags = self._map:getData(pos, 'tags')
	if (tags[tag]) then
		return
	end

	tags[tag] = true

	if (self._tags[tag] == nil) then
		self._tags[tag] = {}
	end
	table.insert(self._tags[tag], Position(pos))

	self.ev:trigger('state_changed')
end

function TagManager:removeTag(pos, tag)
	assertParameter(pos, 'pos', Position)
	assertParameter(tag, 'tag', 'string')

	local tags = self._map:getData(pos, 'tags')
	if (tags[tag] ~= true) then
		return
	end

	tags[tag] = nil

	if (self._tags[tag] ~= nil) then
		for i = #self._tags[tag], 1, -1 do
			if (self._tags[tag][i] == pos) then
				table.remove(self._tags[tag], i)
			end
		end
	end

	self.ev:trigger('state_changed')
end

function TagManager:getTags()
	local r = {}

	for tag, _ in pairs(self._tags) do
		table.insert(r, tag)
	end

	return r
end
