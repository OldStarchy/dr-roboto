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

local ProcessManager = include 'runtime/ProcessManager'
local procMan = ProcessManager()

_G.process = procMan:getAPI()

-- local elpid =
-- 	procMan:spawnProcess(
-- 	function()
-- 		local s = Surface(11, 13)
-- 		s:startMirroring(term.current(), 22, 1)
-- 		local st = s:asTerm()
-- 		while true do
-- 			local ed = {os.pullEvent()}

-- 			local pt = term.current()
-- 			local cp = {term.getCursorPos()}
-- 			term.redirect(st)
-- 			print(ed[1])
-- 			term.redirect(pt)
-- 			term.setCursorPos(unpack(cp))
-- 			term.setCursorBlink(true)
-- 		end
-- 	end,
-- 	'Event Logger'
-- )

procMan:spawnProcess(
	function()
		hud = Hud()
		hud:start()

		-- procMan:sendTerminate(elpid)
	end
)

procMan:run()

print('Goodbye')
sleep(1)
