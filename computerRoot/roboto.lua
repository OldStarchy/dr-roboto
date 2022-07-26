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
