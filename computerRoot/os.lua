include 'Core/_main'
include 'UserFunctions/_main'

-- loadfile('test.lua')(1)

Mov:trackLocation('.mov.tbl')

info('Loading skills')
skillSet = SkillSet.GetDefaultSkillSet()
info(skillSet:getSkillCount() .. ' slills')

info('Loading TaskManager')
taskManager = TaskManager()
pcall(
	function()
		taskManager:load('data/tasks')
	end
)

print('OK')
--TODO: don't actually sleep cus thats slow
-- sleep(1)

local runKernal = true

local coroutines = {}
local tFilters = {}
local eventData = {}

--TODO: write api for kernal

table.insert(
	coroutines,
	coroutine.create(
		function()
			suppressMissingGlobalWarnings(true)
			hud = Hud()
			hud:start()
			-- os.run({}, 'rom/programs/shell')
			suppressMissingGlobalWarnings(false)
		end
	)
)

while runKernal and #coroutines > 0 do
	local n = 1
	while n <= #coroutines do
		local r = coroutines[n]

		if tFilters[r] == nil or tFilters[r] == eventData[1] or eventData[1] == 'terminate' then
			local ok, param = coroutine.resume(r, table.unpack(eventData))

			--TODO: handle crashed routine
			if not ok then
				error(param, 0)
			else
				tFilters[r] = param
			end

			if coroutine.status(r) == 'dead' then
				table.remove(coroutines, n)
				n = n - 1
			end
		end
		n = n + 1
	end
	eventData = {os.pullEventRaw()}
end

if (#coroutines == 0) then
	print('Goodbye')
	sleep(1)
	return
end
