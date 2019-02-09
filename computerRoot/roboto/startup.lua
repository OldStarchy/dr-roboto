log.info('Loading libraries')
include 'Core/_main'
include 'UserFunctions/_main'

if (not os.isPc()) then
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
end

runWithLogging(
	function()
		log.info('Restoring location')
		mov = Class.LoadOrNew('data/mov.tbl', MoveManager, turtle)
		StateSaver.BindToFile(mov, 'data/mov.tbl', 'turtle_moved')

		nav = Navigator(mov)

		log.info('Loading skills')
		skillSet = SkillSet.GetDefaultSkillSet()
		log.info(skillSet:getSkillCount() .. ' skills')

		log.info('Loading TaskManager')
		taskManager = TaskManager()
		taskManager:load('data/tasks')

		log.info('Loading ItemInfo')
		ItemInfo.Instance = ItemInfo()
		ItemInfo.Instance:loadHardTable('data/item.dictionary')

		log.info('Loading RecipeBook')
		RecipeBook.Instance = RecipeBook.LoadFromFile('data/recipe.dictionary.tbl', true)

		log.info('Loading BlockMap')
		BlockMap.Instance = BlockMap.LoadFromFile('data/blockmap.dictionary.tbl', true)
		-- include 'Crafting/StandardRecipes'

		if (fs.exists('data/Map.tbl')) then
			Map.Instance = Map.Deserialize(fs.readTableFromFile('data/Map.tbl'))
		else
			Map.Instance = Map()
		end
		local function saveMap()
			fs.writeTableToFile('data/Map.tbl', Map.Instance:serialize())
		end
		Map.Instance.ev:on('tag_added', saveMap)
		Map.Instance.ev:on('tag_removed', saveMap)
		--TODO: load tags from disc
	end
)

if (os.isPc()) then
	log.info('Running on pc')

	-- runWithLogging(loadfile('test.lua', _G))
	if (fs.exists('mystartup.lua')) then
		runWithLogging(loadfile('mystartup.lua', _G))
	end

	return
end

process.spawnProcess(loadfile('services/CrashMonitor.lua', _G), 'crash monitor', true)
process.spawnProcess(loadfile('services/RemoteMonitorClient.lua'), 'remote monitor', true)
