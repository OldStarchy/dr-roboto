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
List = Class()
List.ClassName = 'List'

function List:constructor()
	self._data = {}
end

function List:insert(item)
	table.insert(self._data, item)
end

function List:pop()
	local minScore = 100000000
	local minId = 1

	for i, v in ipairs(self._data) do
		if (self._data[i].score < minScore) then
			minScore = self._data[i].score
			minId = i
		end
	end

	return table.remove(self._data, minId)
end

function List:count()
	return #self._data
end

function Map:findPath(start, ed)
	assertType(start, Position)
	assertType(ed, Position)

	if (self:isProtected(ed)) then
		error("can't navigate to protected location", 2)
	end

	local open = List()
	open:insert(self:_updateScore(self:_createNode(start), ed))

	local closed = {}
	local goal = nil

	local nodesChecked = 0

	while (goal == nil and open:count() > 0) do
		local curr = open:pop()

		local steps = self:_getPossibleSteps(curr)

		for _, step in ipairs(steps) do
			if (step.position:isEqual(ed)) then
				goal = step
				break
			end

			if (not self:isProtected(step.position)) then
				self:_updateScore(step, ed)

				local posHash = step.position:hash()

				local ex = closed[posHash]
				if (ex ~= nil) then
					if (step.score < ex.score) then
						closed[posHash] = step
					end
				else
					open:insert(step)
				end
			end
		end

		closed[curr.position:hash()] = curr
		nodesChecked = nodesChecked + 1

		if (goal == nil and nodesChecked > 1000) then
			error('Search limit reached in pathfinding')
		end
	end

	if (goal == nil) then
		return nil
	end

	local path = {}
	local gPath = {}

	local curr = goal

	table.insert(path, curr.position)
	table.insert(gPath, curr.g)
	while (curr.parent ~= nil) do
		curr = curr.parent
		table.insert(path, 1, curr.position)
		table.insert(gPath, 1, curr.g)
	end

	local gPathStr = ''
	local currG = ''
	local currC = 0

	for i, g in ipairs(gPath) do
		if (g == currG) then
			currC = currC + 1
		else
			gPathStr = gPathStr .. currG
			if (currC > 1) then
				gPathStr = gPathStr .. tostring(currC)
			end
			currG = g
			currC = 1
		end
	end

	return path, gPathStr
end

function Map:_createNode(pos, parent, g)
	return {
		position = pos,
		travel = (parent and parent.travel or 0) + 1,
		parent = parent,
		g = g
	}
end

function Map:_getPossibleSteps(node)
	local forward =
		self:_createNode( --
		Position(node.position):add( --
			Position.Offsets[node.position.direction] --
		), --
		node, --
		'f'
	)

	local back =
		self:_createNode( --
		Position(node.position):sub( --
			Position.Offsets[node.position.direction] --
		), --
		node, --
		'b'
	)

	local up =
		self:_createNode( --
		Position(node.position):add( --
			{y = 1} --
		), --
		node, --
		'u'
	)

	local down =
		self:_createNode( --
		Position(node.position):add( --
			{y = -1} --
		), --
		node, --
		'd'
	)

	local left =
		self:_createNode( --
		Position(node.position):rotate(1), --
		node, --
		'l'
	)

	local right =
		self:_createNode( --
		Position(node.position):rotate(-1), --
		node, --
		'r'
	)

	return {
		up,
		down,
		forward,
		back,
		left,
		right
	}
end

function Map:_updateScore(node, target)
	local dx = node.position.x - target.x
	local dy = node.position.y - target.y
	local dz = node.position.z - target.z
	local dd = node.position:getDirectionOffset(target.direction)

	if (dx < 0) then
		dx = -dx
	end
	if (dy < 0) then
		dy = -dy
	end
	if (dz < 0) then
		dz = -dz
	end
	if (dd < 0) then
		dd = -dd
	end

	node.score = node.travel + dx + dy + dz + (dd / 4)
	return node
end
