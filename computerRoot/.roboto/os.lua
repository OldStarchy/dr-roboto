--Effects:

-- Redefine global `os` table
-- Redefine global `loadfile` function
-- Run all the util files in the global scope
-- Load all the core modules into the global scope
-- Create the root process manager and expose a global api `process`
-- Create the global logger instance `log` and make it write to files in the `/logs` directory
-- Spawn all service daemons
-- Spawn a process that runs the `startup.lua` file in global scope, then runs the built in shell program

local native = os

_G.os =
	setmetatable(
	{},
	{
		__index = native
	}
)
os.native = native

function os.version()
	return 'Dr. Roboto 3.0.0-alpha'
end

local isPc = native.version == nil
function os.isPc()
	return isPc
end

function os.getTempDir()
	return '/.tmp'
end

function os.debugEvents()
	while (true) do
		print(os.pullEvent())
	end
end

function os.sleepAsync(time, callback)
	local timerId = os.startTimer(time)

	local handler = function(id)
		if (id == timerId) then
			os.ev:off(handler)
			callback()
		end
	end

	os.ev:on('timer', handler)

	return {
		cancel = function()
			os.ev:off(handler)
		end
	}
end

local basePath = '/.roboto'
local utilPath = '/' .. fs.combine(basePath, 'util')
local servicePath = '/' .. fs.combine(basePath, 'services')
local modulesPath = '/' .. fs.combine(basePath, 'modules')
local logPath = '/logs'

local write = term.write
local writeLn = print
local pause = function()
end

local function expect(value, ...)
	local actual = type(value)
	local i

	for i = 1, select('#', ...) do
		if (select(i, ...) == actual) then
			return
		end
	end

	local expected = table.concat({...}, ' or ')
	error('Expected ' .. expected .. ', got ' .. actual)
end

-- Redefine loadfile to include full path in stack frames
_G.loadfile = function(filename, mode, env)
	-- Support the previous `loadfile(filename, env)` form instead.
	if type(mode) == 'table' and env == nil then
		mode, env = nil, mode
	end

	expect(filename, 'string')
	expect(mode, 'string', 'nil')
	expect(env, 'table', 'nil')

	local file = fs.open(filename, 'r')
	if not file then
		return nil, 'File not found'
	end

	local func, err = load(file.readAll(), filename, mode, env)
	file.close()
	return func, err
end

function os.update()
	if (fs.exists('tap.lua')) then
		write('Loading updates...')
		local tap, err = loadfile('tap.lua', _G)()

		if (err) then
			print(err)
			writeLn('ERR')
			writeLn(err)
		else
			local context = {}

			tap.download(
				'tap.lua',
				{
					quiet = true,
					force = true
				}
			)
			tap.download(
				'roboto.lua',
				{
					quiet = true,
					force = true
				}
			)

			tap.download(
				'.roboto',
				{
					context = context,
					quiet = true,
					sync = true
				}
			)
			tap.download(
				'lib',
				{
					context = context,
					quiet = true,
					sync = true
				}
			)

			writeLn('OK')
			pause()

			local anyChanges =
				(context.createdFiles or 0) > 0 or --
				(context.replacedFiles or 0) > 0 or --
				(context.deletedFiles or 0) > 0 or --
				(context.deleted or 0) > 0

			return anyChanges, context
		end
	end
end

write('Loading utils...')
local utils = fs.list(utilPath)
for _, util in ipairs(utils) do
	if (util ~= '.' and util ~= '..') then
		if (not fs.isDir(fs.combine(utilPath, util))) then
			loadfile(fs.combine(utilPath, util), _G)()
		end
	end
end
writeLn('OK')
pause()

write('Loading modules...')
local modules = fs.list(modulesPath)
for _, module in ipairs(modules) do
	if (module ~= '.' and module ~= '..') then
		if (not fs.isDir(fs.combine(modulesPath, module))) then
			loadfile(fs.combine(modulesPath, module), _G)()
		end
	end
end
writeLn('OK')
pause()

local procMan = ProcessManager()
_G.process = procMan:createAPI()

_G.log = Logger()

log:addWriter(FileWriter(fs.combine(logPath, 'log')))
log:info('Log initialized at ' .. tostring(os.time()))

os.ev = EventManager()

local services = fs.list(servicePath)
table.sort(services)

write('Loading services...')
for _, service in ipairs(services) do
	if (service ~= '.' and service ~= '..') then
		if (not fs.isDir(fs.combine(servicePath, service))) then
			local chunk, err = loadfile(fs.combine(servicePath, service))

			if (chunk) then
				log:info('Loading service ' .. service)

				local daemon = stringutil.startsWith(service, 'daemon_')
				local proc =
					procMan:spawnProcess(
					function()
						chunk()
					end,
					service,
					daemon
				)
			else
				log:error('Failed to load service ' .. service .. ': ' .. err)
			end
		end
	end
end
writeLn('OK')
pause()

process.spawnProcess(
	function()
		write('Running startup script...')
		pause()
		runWithLogging(
			function()
				loadfile(fs.combine(basePath, 'startup.lua'), _G)()
			end,
			function(err)
				print(err)
				read()
				os.reboot()
			end
		)
		writeLn('OK')
		pause()

		os.run({}, '/rom/programs/shell.lua')
	end,
	'shell',
	false
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
	-- print('Goodbye')
	-- sleep(1)
	log:info('Shutdown safely')
end
