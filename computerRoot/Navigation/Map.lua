Map = Class()
Map.ClassName = 'Map'

--[=[
	Events:
	tag_added (position, tag)
	tag_removed (position, oldTag)
]=]

function Map:constructor()
	self.ev = EventManager()

	self._points = {}
	self._tags = {}
end

function Map:_getData(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if (self._points[x] == nil) then
		return nil
	end

	if (self._points[x][y] == nil) then
		return nil
	end

	return self._points[x][y][z]
end

function Map:_getOrCreateData(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if (self._points[x] == nil) then
		self._points[x] = {}
	end

	if (self._points[x][y] == nil) then
		self._points[x][y] = {}
	end

	if (self._points[x][y][z] == nil) then
		self._points[x][y][z] = {}
	end

	return self._points[x][y][z]
end

function Map:deleteTag(tag)
	assertType(tag, 'string')

	if (self._tags[tag] ~= nil) then
		self:clearTag(pos)
	end
end

function Map:clearTag(pos)
	assertType(pos, Position)

	local data = self:_getData(pos)

	if (data == nil) then
		return
	end

	local tag = data.tag
	data.tag = nil

	if (tag ~= nil) then
		self.ev:trigger('tag_removed', pos, tag)
		self.ev:trigger('state_changed')
	end
end

function Map:setTag(pos, tag)
	assertType(pos, Position)
	assertType(tag, 'string')

	if (self._tags[tag] ~= nil) then
		self:clearTag(pos)
	end

	local data = self:_getOrCreateData(pos)
	data.tag = tag

	self._tags[tag] = Position(pos)

	self.ev:trigger('tag_added', pos, tag)
	self.ev:trigger('state_changed')
end

function Map:getTags()
	local r = {}

	for i, v in pairs(self._tags) do
		r[i] = Position(v)
	end

	return r
end

function Map:setProtected(pos, protected)
	assertType(pos, Position)

	local data = self:_getOrCreateData(pos)
	data.protected = protected
end

function Map:isProtected(pos)
	assertType(pos, Position)

	local data = self:_getData(pos)

	if (data == nil) then
		return false
	end

	return data.protected
end

function Map:serialize()
	return cloneTable(self._points, 10)
end

function Map.Deserialize(points)
	local map = Map()

	for x, yzdata in pairs(points) do
		for y, zdata in pairs(yzdata) do
			for z, data in pairs(zdata) do
				if (data.tag ~= nil) then
					map:setTag(Position(x, y, z), data.tag)
				end
				if (data.protected) then
					map:setProtected(Position(x, y, z), true)
				end
			end
		end
	end

	return map
end
