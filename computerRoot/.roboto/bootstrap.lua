_G._roboto = {
	verbose = false
}

-- TODO: check for updates
-- if (settings.get('roboto.autoUpdate') == true) then
-- 	print('Checking for updates...')
-- 	-- TODO: http HEAD request to get latest version number
-- 	-- compare with current version number
-- 	if (update ~= nil) then
-- 		local updateFile = fs.open('/tmp/update.lua', 'w')
-- 		updateFile.write(update.readAll())
-- 		updateFile.close()
-- 		print('Update found. Restarting...')
-- 		os.sleep(1)
-- 		os.reboot()
-- 	end
-- end

-- Disable multishell
if (settings ~= nil) then
	if (multishell ~= nil) then
		settings.set('bios.use_multishell', false)
		settings.save('.settings')
		os.reboot()
	end
end

-- debug_break is used when debugging on PC, noop required when running in CC
if (_G.debug_break == nil) then
	_G.debug_break = function()
	end
end

local basePath = '/.roboto'

local isPc = os.version == nil
if (isPc) then
	print('Running on PC - loading polyfills')
	require 'lfs'
	lfs.chdir('computerRoot')
	dofile '../_polyfills/_main.lua'

	dofile '.roboto/os.lua'
	return
end

local drRobotoIsLoaded = os.version and os.version():sub(1, 10) == 'Dr. Roboto'

if (not drRobotoIsLoaded) then
	os.run(_ENV, fs.combine(basePath, 'os.lua'))

	shell.exit()
end
