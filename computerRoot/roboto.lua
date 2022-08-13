local robotoIsInstalled = fs.exists('.roboto')
local robotoIsLoaded = os.version and os.version():sub(1, 10) == 'Dr. Roboto'

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

local function askToInstallRoboto()
	local cursorBlink = term.getCursorBlink()

	print('Roboto not installed')
	print('Do you want to install it [yN]?')
	term.setCursorBlink(true)

	repeat
		local event, char = os.pullEvent('char')
		if (char == 'y') then
			term.setCursorBlink(false)
			installRoboto()
			return
		end
	until (char == 'n')

	print('ok.')
	term.setCursorBlink(cursorBlink)
	return
end

local function startRoboto()
	if (not robotoIsLoaded) then
		if (fs.exists('.roboto-crashed')) then
			print('Roboto has crashed. Delete the .roboto-crashed file to clear this message.')
			return
		end
		fs.open('.roboto-crashed', 'w').close()

		_G.shell = shell

		local sd = os.shutdown
		os.shutdown = function()
			if (fs.exists('.roboto-crashed')) then
				read()
				os.reboot()
			else
				sd()
			end
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
		return
	end
end

local args = {...}

if (#args == 0) then
	-- running from wget run
	if (not robotoIsInstalled) then
		askToInstallRoboto()
		return false
	end

	-- running from initial startup
	if (not robotoIsLoaded) then
		startRoboto()
		return false
	end

	return robotoIsLoaded
end

if (#args == 1) then
	if (args[1] == 'update') then
		updateRoboto()
		return false
	end

	print('Unknown argument: ' .. args[1])
	return false
end
