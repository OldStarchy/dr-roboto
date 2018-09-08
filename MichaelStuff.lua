function goToGround()
	while (turtle.down()) do
		local success, data = turtle.inspectDown()
	end
end

function quarry(maxRadius)
	local depth = 0
	while lineDown(1) do
		depth = depth + 1
		concentricSquare(maxRadius)
		turtle.turnLeft()
		line(maxRadius)
		turtle.turnRight()
	end
	lineUp(depth)
end

function concentricSquare(maxRadius)
	for i = 1, maxRadius do
		turtle.turnRight()
		if not line(1) then
			return false
		end
		turtle.turnLeft()
		if not square(i) then
			return false
		end
	end
	return true
end

function square(radius)
	if not line(radius) then
		return false
	end
	turtle.turnLeft()
	for i = 1, 3 do
		if not line(radius * 2) then
			return false
		end
		turtle.turnLeft()
	end
	if not line(radius) then
		return false
	end
	return true
end

function lineDown(len)
	for i = 1, len do
		if not (turtle.down() or turtle.digDown() and turtle.down()) then
			return false
		end
	end
	return true
end

function lineUp(len)
	for i = 1, len do
		if not (turtle.up() or turtle.digUp() and turtle.up()) then
			return false
		end
	end
	return true
end

function line(len)
	for i = 1, len do
		if not (turtle.forward() or turtle.dig() and turtle.forward()) then
			return false
		end
	end
	return true
end

localArgs = {...}
env = getfenv()
if #localArgs > 0 then
	if (type(env[localArgs[1]]) == 'function') then
		local funcName = table.remove(localArgs, 1)
		local oldDig = Nav.autoDig
		local oldAttack = Nav.autoAttack
		Nav.autoDig = true
		Nav.autoAttack = true
		env[funcName](unpack(localArgs))
		Nav.autoDig = oldDig
		Nav.autoAttack = oldAttack
	end
end
