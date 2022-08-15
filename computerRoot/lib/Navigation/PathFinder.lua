includeOnce '../Data/OrderedList'
includeOnce '../Data/Position'

PathFinder = Class()
PathFinder.ClassName = 'PathFinder'

function PathFinder:constructor(map)
	self._map = assertType(map, Map)
end

function PathFinder:findPath(start, ed, limitSteps, reverse)
	assertType(start, Position)
	assertType(ed, Position)

	if (reverse) then
		if (limitSteps) then
			error('cant reverse and lmiit steps')
		end
		start, ed = ed, start
	end

	local mapDebug = cloneTable(self._map)

	local function countEntries(tbl)
		local count = 0
		for _, _ in pairs(tbl) do
			count = count + 1
		end
		return count
	end

	if (self._map:isProtected(ed)) then
		error("can't navigate to protected location", 2)
	end

	local open = OrderedList()
	open:insert(self:_updateScore(self:_createNode(start), ed))

	local closed = {}
	local goal = nil

	local function saveMapDebug(path)
		for _, node in pairs(closed) do
			mapDebug:setProtected(node.position, true, 'Closed', 128, 0, 0)
		end
		for _, node in ipairs(open:getItems()) do
			mapDebug:setProtected(node.position, true, 'Open', 0, 128, 0)
		end
		if (path) then
			for _, pos in pairs(path) do
				mapDebug:setProtected(pos, true, 'Path', 128, 0, 128)
			end
		end
		mapDebug:setProtected(start, true, 'Start', 0, 255, 0)
		mapDebug:setProtected(ed, true, 'End', 255, 0, 0)
		mapDebug:saveToVoxelsVox('pathfinder_debug.vox')
	end

	local iterationsPerYield = 100
	local iterationsSinceYield = 0
	local fullPath = true
	local _, lineY = term.getCursorPos()

	while (goal == nil and open:count() > 0) do
		iterationsSinceYield = iterationsSinceYield + 1

		if (iterationsSinceYield >= iterationsPerYield) then
			iterationsSinceYield = 0
			-- local closest = open:peek()
			-- term.setCursorPos(1, lineY - 2)
			-- term.clearLine()
			-- term.write('Open: ' .. open:count() .. '  Closed: ' .. countEntries(closed))
			-- term.setCursorPos(1, lineY - 1)
			-- term.clearLine()
			-- term.write(tostring(closest.position) .. ' ' .. tostring(closest.position:clone():distanceTo(ed)))
			os.startTimer(0)
			os.pullEvent()
		end

		local curr = open:pop()

		if (limitSteps) then
			if (curr.travel > limitSteps) then
				goal = curr
				fullPath = false
				break
			end
		end
		local steps = self:_getPossibleSteps(curr)

		for _, step in ipairs(steps) do
			if (step.position:posEquals(ed)) then
				goal = step
				break
			end

			if (not self._map:isProtected(step.position)) then
				self:_updateScore(step, ed)

				local posHash = step.position:posHash()

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

		closed[curr.position:posHash()] = curr

		if (goal == nil and countEntries(closed) > 200) then
			saveMapDebug()
			error('Search limit reached in pathfinding')
		end
	end

	if (goal == nil) then
		saveMapDebug()
		return nil
	end

	local path = {}

	local curr = goal

	table.insert(path, curr.position)
	while (curr.parent ~= nil) do
		curr = curr.parent
		if (reverse) then
			table.insert(path, curr.position)
		else
			table.insert(path, 1, curr.position)
		end
	end

	saveMapDebug(path)
	return path, fullPath
end

function PathFinder:_createNode(pos, parent, intrinsic)
	local data = self._map:getData(pos)
	local isClear = data and data.protected == false or false
	return {
		position = pos,
		travel = (parent and parent.travel or 0) + 1,
		intrinsic = (isClear and 0 or (intrinsic or 0)),
		parent = parent
	}
end

function PathFinder:_getPossibleSteps(node)
	local steps = {
		self:_createNode(Position(node.position):add({x = 1, y = 0, z = 0}), node, 0),
		self:_createNode(Position(node.position):add({x = -1, y = 0, z = 0}), node, 0),
		self:_createNode(Position(node.position):add({x = 0, y = 0, z = 1}), node, 0),
		self:_createNode(Position(node.position):add({x = 0, y = 0, z = -1}), node, 0),
		self:_createNode(Position(node.position):add({x = 0, y = 1, z = 0}), node, 0),
		self:_createNode(Position(node.position):add({x = 0, y = -1, z = 0}), node, 1) -- penalize moving down as probably ground is ther
	}

	return steps
end

function PathFinder:_updateScore(node, target)
	local dx = node.position.x - target.x
	local dy = node.position.y - target.y
	local dz = node.position.z - target.z
	local dd = 0 --node.position:getDirectionOffset(target.direction)

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

	node.score = node.travel + (dx + dy + dz) * 1.1 + (dd / 4) + node.intrinsic
	return node
end
