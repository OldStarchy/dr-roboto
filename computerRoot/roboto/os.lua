local native = os
os =
	setmetatable(
	{},
	{
		__index = native
	}
)
os.native = native

function os.version()
	return 'Dr. Roboto 1.0'
end

local isPc = false
if (native.version == nil) then
	isPc = true
end

function os.isPc()
	return isPc
end

--Setup OS environment

print('Loading utils...')
local utils = fs.list('roboto/util')
for _, util in ipairs(utils) do
	if (util ~= '.' and util ~= '..') then
		loadfile('roboto/util/' .. util, _G)()
	end
end
print('OK')

local components = {
	'debug',
	'fs',
	'vfs',
	'loader',
	'class',
	'types',
	'missingGlobals',
	'log',
	'runWithLogging',
	'ProcessManager'
}

for _, component in ipairs(components) do
	term.write('Loading ' .. component .. '...')
	loadfile('roboto/component/' .. component .. '.lua', _G)()
	print('OK')
end

local procMan = ProcessManager()
_G.process = procMan:getAPI()

--[[ Initialize the logger ]]
log.addWriter(loadfile('roboto/component/logPrintWriter.lua', _G)())

--shuffle log backups
if (fs.exists('logs/latest.log')) then
	if (fs.exists('logs/backup.log')) then
		if (fs.exists('logs/backup2.log')) then
			fs.delete('logs/backup2.log')
		end
		fs.move('logs/backup.log', 'logs/backup2.log')
	end

	fs.move('logs/latest.log', 'logs/backup.log')
end
log.addWriter(loadfile('roboto/component/logFileWriter.lua', _G)('logs/latest.log'))

log.info('Log initialized at ' .. tostring(os.time()))

--[[ Business logic starts here ]]
if (isPc) then
	log.info('Running on pc')

	runWithLogging(loadfile('test.lua', _G))

	return
end

runWithLogging(loadfile('roboto/startup.lua', _G))

process.spawnProcess(
	function()
		hud = Hud()
		hud:start()

		-- process.sendTerminate(elpid)
	end,
	'hud'
)

local ok, err =
	runWithLogging(
	function()
		procMan:run()
	end
)
-- If the shell errored, let the user read it.
-- term.redirect(term.native())
if not ok then
	printError(err)
	printStackTrace(1)
	pcall(
		function()
			term.setCursorBlink(false)
			print('Press any key to continue')
			os.pullEvent('key')
		end
	)
else
	log.info('Shutdown safely')
	print('Goodbye')
	sleep(1)
end
