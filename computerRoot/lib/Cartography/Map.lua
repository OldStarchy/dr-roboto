Map = Class()
Map.ClassName = 'Map'

function Map:constructor()
	self.ev = EventManager()

	self._points = {}
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
