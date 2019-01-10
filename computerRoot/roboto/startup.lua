log.info('Loading libraries')
include 'Core/_main'
include 'UserFunctions/_main'

suppressMissingGlobalWarnings(false)

print('Running startup in 2 seconds')
term.write('Press enter to skip ... ')

term.setCursorBlink(true)
local tid = os.startTimer(2)

local event, id = os.pullEvent()
local wait = true
while (wait) do
	if (event == 'timer' and id == tid) then
		print('running')
		loadfile('less')('run', 'test')
		break
	elseif (event == 'key' and id == 28) then
		print('skipping')
		break
	end
	event, id = os.pullEvent()
end

runAndPrintErrLines(
	function()
		log.info('Restoring location')
		Mov:trackLocation('.mov.tbl')

		log.info('Loading skills')
		skillSet = SkillSet.GetDefaultSkillSet()
		log.info(skillSet:getSkillCount() .. ' slills')

		log.info('Loading TaskManager')
		taskManager = TaskManager()
		taskManager:load('data/tasks')

		log.info('Loading ItemInfo')
		ItemInfo.Instance = ItemInfo()
		ItemInfo.Instance:loadHardTable('item.dictionary')

		log.info('Loading RecipeBook')
		RecipeBook.Instance = RecipeBook.LoadFromFile('recipe.dictionary.tbl', true)
		-- include 'Crafting/StandardRecipes'

		if (fs.exists('mystartup.lua')) then
			log.info('Running mystartup.lua')
			dofile('mystartup.lua')
		end
	end
)

-- Print call logging
-- local oldPrint = print
-- _G.print = function(...)
-- 	local st = getStackTrace(1, 2)[1]
-- 	oldPrint(st, ...)
-- end
