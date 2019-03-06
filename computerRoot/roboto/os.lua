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

term.write('Loading utils...')
local utils = fs.list('roboto/util')
for _, util in ipairs(utils) do
	if (util ~= '.' and util ~= '..') then
		if (not fs.isDir('roboto/util/' .. util)) then
			loadfile('roboto/util/' .. util, _G)()
		end
	end
end
print('OK')

local components = {
	'debug',
	'fs',
	'vfs',
	'loader',
	'class',
	'interface',
	'types',
	'missingGlobals',
	'log',
	'runWithLogging',
	'ProcessManager',
	'EventManager'
}

for _, component in ipairs(components) do
	term.write('Loading ' .. component .. '...')
	loadfile('roboto/component/' .. component .. '.lua', _G)()
	print('OK')
end

print()

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

	if
		(not pcall(
			function()
				fs.move('logs/latest.log', 'logs/backup.log')
			end
		))
	 then
		error(
			"Couldn't copy log files\nProbably because the file is locked by another computer with the same id or the shell is running on pc"
		)
	end
end

if (not fs.exists('logs')) then
	fs.makeDir('logs')
end

log.addWriter(loadfile('roboto/component/logFileWriter.lua', _G)('logs/latest.log'))

log.info('Log initialized at ' .. tostring(os.time()))

runWithLogging(loadfile('roboto/startup.lua', _G))

--[[ Business logic starts here ]]
if (isPc) then
	return
end

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
