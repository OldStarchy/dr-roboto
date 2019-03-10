local state = {}
local function tryRefuel(direction)
	if (inv:pushSelection('bucket')) then
		if (inv:hasEmpty()) then
			if (turtle['place' .. direction]()) then
				log.info('Refueled from lava source')
				inv:select('lava_bucket')
				turtle.refuel(1)
			end
		else
			log.info('No room to pick up lava for refueling')
		end
	end
	inv:popSelection()
end

local function shouldDig(state, detail)
	local dig = true

	if (detail:matches('dirt') or detail:matches('grass')) then
		dig = inv:countItem('dirt') < 10
	elseif (detail:matches('stone:0,cobblestone')) then
		dig = inv:countItem('cobblestone') < 10
	end

	return dig
end

local function check(state, direction)
	local item, detail = turtle['inspect' .. direction]()

	if (item) then
		log.info('found ' .. detail:getId())

		if (detail:matches('lava')) then
			if (detail.metadata == 0) then
				-- source block
				tryRefuel(direction)
			end
		end

		if (detail:isLiquid()) then
			log.info('liquid, blocking off')
			if (inv:pushSelection('cobblestone,dirt')) then
				turtle['place' .. direction]()
			else
				log.info('nothing to block it off with')
			end
			inv:popSelection()
		else
			if (shouldDig(state, detail)) then
				turtle['dig' .. direction]()
			end
		end
	end
end

local function dig(state)
	for i = 1, state.length do
		turtle.dig()
		mov:forward()

		check(state, 'Up')
		check(state, 'Down')
	end

	mov:turnRight()
	turtle.dig()
	mov:forward()
	mov:turnRight()

	for i = 1, state.length do
		turtle.dig()
		mov:forward()

		check(state, 'Up')
		check(state, 'Down')
	end
end

local function goToRow(state)
	local x = math.floor(state.count / state.steps) * 2
	local y = state.startY + (state.count % state.steps) * 3

	local pos = Position(state.startPosition.x + x, y, state.startPosition.z)

	mov:push(true, true)
	nav:goTo(pos)

	mov:pop()
	return mov:face(Position.NORTH) -- negative z
end

local function shouldContinue(state)
	if (state.maxColumns > 0 and state.count > state.maxColumns) then
		return false
	end

	local r = state.ev:trigger('row_start')

	for _, v in pairs(r) do
		if (v == false) then
			return false
		end
	end

	return true
end

local function resume(state)
	mov:push(true, true)
	nav:goToY(state.startY)
	mov:pop()

	while (shouldContinue(state)) do
		goToRow(state)
		dig(state)
		state.count = state.count + 1
	end

	mov:push(true, true)
	nav:goTo(state.startPosition)
	mov:pop()
end

local defaults = {
	count = 0,
	startY = 6,
	endY = 15,
	maxColumns = 5,
	length = 16
}

return function(oldState)
	local state = oldState or {}

	state.ev = EventManager()

	state.start = function()
		mergeTables(
			state,
			defaults,
			{
				startPosition = mov:getPosition()
			}
		)

		state.steps = math.floor((state.endY - state.startY) / 3) + 1

		resume(state)
	end

	return state
end
