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

function os.isPc()
	return isPc
end

function os.getTempDir()
	return '/.tmp'
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

local join = fs.combine
local isPc = native.version == nil

local basePath = '/.roboto'
local utilPath = '/' .. join(basePath, 'util')
local servicePath = '/' .. join(basePath, 'services')
local modulesPath = '/' .. join(basePath, 'modules')
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

write('Loading utils...')
local utils = fs.list(utilPath)
for _, util in ipairs(utils) do
	if (util ~= '.' and util ~= '..') then
		if (not fs.isDir(join(utilPath, util))) then
			loadfile(join(utilPath, util), _G)()
		end
	end
end
writeLn('OK')
pause()

write('Loading modules...')
local modules = fs.list(modulesPath)
for _, module in ipairs(modules) do
	if (module ~= '.' and module ~= '..') then
		if (not fs.isDir(join(modulesPath, module))) then
			loadfile(join(modulesPath, module), _G)()
		end
	end
end
writeLn('OK')
pause()

local procMan = ProcessManager()
_G.process = procMan:createAPI()

local logger = Logger()
logger:addWriter(FileWriter(join(logPath, 'log')))
_G.log = logger

log:info('Log initialized at ' .. tostring(os.time()))

os.ev = EventManager()

local services = fs.list(servicePath)
table.sort(services)

write('Loading services...')
for _, service in ipairs(services) do
	if (service ~= '.' and service ~= '..') then
		if (not fs.isDir(join(servicePath, service))) then
			local chunk, err = loadfile(join(servicePath, service))

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
		if (fs.exists('/startup.lua')) then
			runWithLogging(
				function()
					loadfile('/startup.lua', _G)()
				end
			)
		end
		writeLn('OK')
		pause()

		os.run(_ENV, '/rom/programs/shell.lua')
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
