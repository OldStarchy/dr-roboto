local function installRoboto()
	if (not fs.exists('/tap.lua')) then
		shell.run('wget http://sorokin.id.au/tap.lua tap.lua')
		if (not fs.exists('/tap.lua')) then
			print('Failed to download tap.lua')
			return
		end
	end

	shell.run('tap.lua -f -s .roboto')
	shell.run('tap.lua -f -s lib')
	shell.run('tap.lua -f roboto.lua')

	shell.run('tap.lua -f -b startup.lua')
	shell.run('tap.lua -f -b test.lua')
	shell.run('tap.lua -f -b uncrash.lua')

	if (turtle) then
		shell.run('tap.lua -f -s Go')
		shell.run('tap.lua -f g')
		shell.run('tap.lua -f -b getfuel.lua')
	end

	if (fs.exists('.roboto-crashed')) then
		fs.delete('.roboto-crashed')
	end

	print('Roboto installed')
	print('Press enter to reboot')
	read()
	os.reboot()
	return
end

local function updateRoboto()
	if (not fs.exists('/tap.lua')) then
		shell.run('wget http://sorokin.id.au/tap.lua tap.lua')
		if (not fs.exists('/tap.lua')) then
			print('Failed to download tap.lua')
			return
		end
	end

	shell.run('tap.lua -f -s .roboto')
	shell.run('tap.lua -f -s lib')
	shell.run('tap.lua -f roboto.lua')
	shell.run('tap.lua -f startup.lua')

	if (fs.exists('.roboto-crashed')) then
		fs.delete('.roboto-crashed')
	end

	print('Roboto updated')
	print('Press enter to reboot')
	read()
	os.reboot()
	return
end

local args = {...}

if (#args > 0) then
	if (args[1] == 'update') then
		updateRoboto()
		return
	end

	print('Unknown argument: ' .. args[1])
	return
end

if (not fs.exists('/.roboto')) then
	print('Roboto not installed')
	print('Do you want to install it [yN]?')

	repeat
		local event, char = os.pullEvent('char')
		if (char == 'y') then
			installRoboto()
			return
		end
	until (char == 'n')

	print('ok.')
	return
end

local drRobotoIsLoaded = os.version and os.version():sub(1, 10) == 'Dr. Roboto'

if (drRobotoIsLoaded) then
	print('Roboto already loaded')
	return
end

local sd = os.shutdown
os.shutdown = function()
	read()
	os.reboot()
end

xpcall(
	function()
		-- Load Roboto OS
		os.run(_ENV, '.roboto/bootstrap.lua')
	end,
	function(error)
		print(error)
		read()
	end
)
