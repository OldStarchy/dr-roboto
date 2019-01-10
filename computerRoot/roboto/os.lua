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
		loadfile('roboto/util/' .. util, getfenv())()
	end
end
print('OK')

local components = {
	'debug',
	'log',
	'fs',
	'vfs',
	'loader',
	'class',
	'types'
}

for _, component in ipairs(components) do
	term.write('Loading ' .. component .. '...')
	loadfile('roboto/component/' .. component .. '.lua', getfenv())()
	print('OK')
end

log.addWriter(loadfile('roboto/component/logPrintWriter.lua', getfenv())())
if (fs.exists('logs/latest.log')) then
	if (fs.exists('logs/backup.log')) then
		if (fs.exists('logs/backup2.log')) then
			fs.delete('logs/backup2.log')
		end
		fs.move('logs/backup.log', 'logs/backup2.log')
	end

	fs.move('logs/latest.log', 'logs/backup.log')
end
log.addWriter(loadfile('roboto/component/logFileWriter.lua', getfenv())('logs/latest.log'))

log.info('Log initialized at ' .. tostring(os.time()))

local ignoreMissingGlobal = false
local ignoreMissingGlobals = {
	_PROMPT = true,
	_PROMPT2 = true,
	multishell = true
}
setmetatable(
	_G,
	{
		__index = function(t, v)
			if (ignoreMissingGlobals[v] or ignoreMissingGlobal) then
				return nil
			end
			print('Attempt to access missing global "' .. tostring(v) .. '"')
			printStackTrace(2, 1)
			return nil
		end
	}
)
function suppressMissingGlobalWarnings(suppress)
	ignoreMissingGlobal = suppress
end
function isDefined(key)
	ignoreMissingGlobal = true
	local isDef = getfenv(2)[key] ~= nil
	ignoreMissingGlobal = false
	return isDef
end

local function runWithLogging(func)
	return xpcall(
		func,
		function(err)
			local trace = getStackTrace(20, 2)
			trace[1] = err

			for _, err in pairs(trace) do
				local frameInfo = getStackFrameInfo(err)

				local errLine =
					stringutil.join(
					{
						frameInfo.file,
						frameInfo.line,
						frameInfo.message
					},
					':'
				) .. ':'

				log.error(errLine)

				if (frameInfo.file and frameInfo.line) then
					errLine = getFileLines(frameInfo.file, frameInfo.line, 3)
					if (errLine ~= nil) then
						log.error('\t' .. string.gsub(errLine, '\n', '\n\t') .. '\n\n')
					end
				end
			end
		end
	)
end

if (isPc) then
	log.info('Running on pc')

	runWithLogging(loadfile('test.lua', getfenv()))

	return
end

runWithLogging(loadfile('roboto/startup.lua', getfenv()))

local ok, err =
	runWithLogging(
	function()
		local ProcessManager = include 'runtime/ProcessManager'
		local procMan = ProcessManager()

		_G.process = procMan:getAPI()

		procMan:spawnProcess(
			function()
				hud = Hud()
				hud:start()

				-- procMan:sendTerminate(elpid)
			end
		)

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
