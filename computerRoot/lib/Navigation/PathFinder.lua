includeOnce '../Data/OrderedList'
includeOnce '../Data/Position'

PathFinder = Class()
PathFinder.ClassName = 'PathFinder'

function PathFinder:constructor(map)
	self._map = assertType(map, Map)
end

function PathFinder:findPath(start, ed)
	assertType(start, Position)
	assertType(ed, Position)

	if (self._map:isProtected(ed)) then
		error("can't navigate to protected location", 2)
	end

	local open = OrderedList()
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

			if (not self._map:isProtected(step.position)) then
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

function PathFinder:_createNode(pos, parent, g)
	return {
		position = pos,
		travel = (parent and parent.travel or 0) + 1,
		parent = parent,
		g = g
	}
end

function PathFinder:_getPossibleSteps(node)
	local forward =
		self:_createNode( --
		node.position:forward(), --
		node, --
		'f'
	)

	local back =
		self:_createNode( --
		node.position:back(), --
		node, --
		'b'
	)

	local up =
		self:_createNode( --
		node.position:up(), --
		node, --
		'u'
	)

	local down =
		self:_createNode( --
		node.position:down(), --
		node, --
		'd'
	)

	local left =
		self:_createNode( --
		node.position:left(), --
		node, --
		'l'
	)

	local right =
		self:_createNode( --
		node.position:right(), --
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

function PathFinder:_updateScore(node, target)
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
