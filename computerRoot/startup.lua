if (not loadfile('roboto.lua', _ENV)()) then
	return
end

if (fs.exists('autorun')) then
	local autorunners = fs.list('autorun')
	for _, autorunner in ipairs(autorunners) do
		local autorunnerPath = fs.combine('autorun', autorunner)
		if (not fs.isDir(autorunnerPath)) then
			shell.run(autorunnerPath)
		end
	end
end
