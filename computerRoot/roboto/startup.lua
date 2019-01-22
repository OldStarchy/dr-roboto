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
		Mov:trackLocation('data/position.tbl')

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
	runWithLogging(loadfile('mystartup.lua', _G))

	return
end

-- Print call logging
-- local oldPrint = print
-- _G.print = function(...)
-- 	local st = getStackTrace(1, 2)[1]
-- 	oldPrint(st, ...)
-- end
process.spawnProcess(
	function()
		local surf = Surface(term.getSize(), 7)
		surf:startMirroring(term.native(), 1, 1)
		local surfTerm = surf:asTerm()

		rednet.open('right')

		while (true) do
			local ev = {os.pullEventRaw()}

			if (ev[1] == 'turtle_inventory' or ev[1] == 'turtle_moved') then
				rednet.broadcast(
					textutils.serialize(
						{
							inventory = Inv:count(),
							location = Mov:getPosition():toString(),
							fuel = turtle.getFuelLevel()
						}
					)
				)
				print(textutils.serialize(ev[1]))
			end
			-- local cterm = term.current()
			-- term.redirect(surfTerm)
			-- term.clear()
			-- term.setCursorPos(1, 1)
			-- print(tableToString(ev))
			-- term.redirect(cterm)
			-- term.setCursorBlink(true)
		end
	end,
	'remote monitor',
	true
)
