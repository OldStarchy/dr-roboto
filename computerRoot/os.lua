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

procMan:spawnProcess(
	function()
		hud = Hud()
		hud:start()
	end
)

procMan:run()

print('Goodbye')
sleep(1)
