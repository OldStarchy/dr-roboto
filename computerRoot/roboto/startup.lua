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
		local function loadAndBind(file, class, event, ...)
			local obj = Class.LoadOrNew(file, class, ...)
			StateSaver.BindToFile(obj, file, event)
			return obj
		end

		log.info('Restoring location')
		mov = loadAndBind('data/mov.tbl', MoveManager, 'turtle_moved', turtle)
		nav = Navigator(mov)

		log.info(#Skill.ChildTypes .. ' skills')

		local singletons = {
			ItemInfo,
			RecipeBook,
			TaskManager,
			TagManager,
			BlockManager
		}

		for _, v in ipairs(singletons) do
			log.info('Loading ' .. v.ClassName)
			v.Instance = loadAndBind('data/' .. string.lower(v.ClassName) .. '.tbl', v)
		end

		Crafting = Crafter(turtle)
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
