-- This is copied directly from bios.lua in the computercraft mod

-- Install the rest of the OS api
function os.run(_tEnv, _sPath, ...)
	local tArgs = {...}
	local tEnv = _tEnv
	setmetatable(tEnv, {__index = _G})
	local fnFile, err = loadfile(_sPath, tEnv)
	if fnFile then
		local ok, err =
			pcall(
			function()
				fnFile(unpack(tArgs))
			end
		)
		if not ok then
			if err and err ~= '' then
				print(err)
			end
			return false
		end
		return true
	end
	if err and err ~= '' then
		print(err)
	end
	return false
end

local tAPIsLoading = {}
function os.loadAPI(_sPath)
	local sName = fs.getName(_sPath)
	if tAPIsLoading[sName] == true then
		print('API ' .. sName .. ' is already being loaded')
		return false
	end
	tAPIsLoading[sName] = true

	local tEnv = {}
	setmetatable(tEnv, {__index = _G})
	local fnAPI, err = loadfile(_sPath, tEnv)
	if fnAPI then
		local ok, err = pcall(fnAPI)
		if not ok then
			print(err)
			tAPIsLoading[sName] = nil
			return false
		end
	else
		print(err)
		tAPIsLoading[sName] = nil
		return false
	end

	local tAPI = {}
	for k, v in pairs(tEnv) do
		if k ~= '_ENV' then
			tAPI[k] = v
		end
	end

	_G[sName] = tAPI
	tAPIsLoading[sName] = nil
	return true
end

function os.unloadAPI(_sName)
	if _sName ~= '_G' and type(_G[_sName]) == 'table' then
		_G[_sName] = nil
	end
end

function os.sleep(nTime)
	sleep(nTime)
end

function os.queueEvent()
end
