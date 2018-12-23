Map = Class()
Map.ClassName = 'Map'

function Map:constructor()
	self._points = {}
	self._tags = {}
end

function Map:_getData(x, y, z)
	if (self._points[x] == nil) then
		return nil
	end

	if (self._points[x][y] == nil) then
		return nil
	end

	return self._points[x][y][z]
end

function Map:_getOrCreateData(x, y, z)
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

function Map:setProtected(x, y, z, protected)
	assertType(x, 'int')
	assertType(y, 'int')
	assertType(z, 'int')

	local data = self:_getOrCreateData(x, y, z)
	data.protected = protected
end

function Map:isProtected(x, y, z)
	assertType(x, 'int')
	assertType(y, 'int')
	assertType(z, 'int')

	local data = self:_getData(x, y, z)

	if (data == nil) then
		return false
	end

	return data.protected
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

	if (self:isProtected(ed.x, ed.y, ed.z)) then
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

			if (not self:isProtected(step.position.x, step.position.y, step.position.z)) then
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

	local curr = goal

	table.insert(path, curr.position)
	while (curr.parent ~= nil) do
		curr = curr.parent
		table.insert(path, 1, curr.position)
	end

	return path
end

function Map:_createNode(pos, parent)
	return {
		position = pos,
		travel = (parent and parent.travel or 0) + 1,
		parent = parent
	}
end

function Map:_getPossibleSteps(node)
	local forward =
		self:_createNode( --
		Position(node.position):add( --
			Position.offsets[node.position.direction] --
		), --
		node --
	)

	local back =
		self:_createNode( --
		Position(node.position):sub( --
			Position.offsets[node.position.direction] --
		), --
		node --
	)

	local up =
		self:_createNode( --
		Position(node.position):add( --
			{y = 1} --
		), --
		node --
	)

	local down =
		self:_createNode( --
		Position(node.position):add( --
			{y = -1} --
		), --
		node --
	)

	local left =
		self:_createNode( --
		Position(node.position):rotate(1), --
		node --
	)

	local right =
		self:_createNode( --
		Position(node.position):rotate(-1), --
		node --
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
