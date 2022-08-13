local version = '0.2.0'
local protocol = 'http'
local domain = 'sorokin.id.au'
local headers = {
	['x-tap'] = version
}
local metaDataFile = '.tap/metaData.tbl'

local function tableToFile(tbl, file)
	local str = textutils.serialize(tbl)
	local f = fs.open(file, 'w')
	f.write(str)
	f.close()
end

local function fileToTable(file)
	local f = fs.open(file, 'r')
	local str = f.readAll()
	f.close()
	return str and textutils.unserialize(str) or {}
end

local function setMetaData(path, value)
	if (fs.exists(metaDataFile)) then
		local metaData = fileToTable(metaDataFile) or {}
		metaData[path] = value
		tableToFile(metaData, metaDataFile)
	else
		local metaData = {}
		metaData[path] = value
		tableToFile(metaData, metaDataFile)
	end
end

local function getMetaData(path)
	if (fs.exists(metaDataFile)) then
		local metaData = fileToTable(metaDataFile)
		if (fs.exists(path)) then
			return metaData[path]
		else
			setMetaData(path, nil)
			return nil
		end
	end

	return nil
end

local function downloadMd5()
	local url = 'https://raw.githubusercontent.com/kikito/md5.lua/4b5ce0cc277a5972aa3f5161d950f809c2c62bab/md5.lua'

	shell.run('wget', url, '.tap/md5.lua')
end

local function loadMd5()
	if (_G.md5) then
		return _G.md5
	end

	if (not fs.exists('.tap/md5.lua')) then
		downloadMd5()
	end

	_G.md5 = dofile('.tap/md5.lua')

	return _G.md5
end

local function getFileMd5(file)
	local md5 = loadMd5()

	local fileHandle = fs.open(file, 'r')
	local fileData = fileHandle.readAll()
	fileHandle.close()

	return md5.sumhexa(fileData)
end

local function getFileHash(file)
	return {
		type = 'md5',
		hash = getFileMd5(file)
	}
end

local function get(file, hash)
	local url = protocol .. '://' .. fs.combine(domain, file)

	local _headers = {}
	for k, v in pairs(headers) do
		_headers[k] = v
	end

	if (hash) then
		_headers['If-None-Match'] = hash.type .. ' ' .. hash.hash
	end

	local response, errorMessage, badResponse = http.get(url, _headers)

	if response then
		if (response.getResponseCode() == 304) then
			return 304, nil
		end
		local data = response.readAll()

		return response.getResponseCode(), data
	else
		return badResponse.getResponseCode(), errorMessage, badResponse.readAll()
	end
end

local function download(file, context, flagForce, flagNoBackup, flagSync, flagQuiet)
	local hash = nil

	-- hashing is disabled for now until
	--  1. i can find something that runs faster than it would take to download the file
	--  2. i can make the text encoding consistent so the same text input will
	--     always hash to the same output in both lua and nodejs

	-- if (not fs.isDir(file) and fs.exists(file) and not flagForce) then
	-- 	hash = getFileHash(file)
	-- end

	local code, data = get(file, hash)

	if (code == 304) then
		if (not flagQuiet) then
			print('unchanged: ' .. file)
		end
		context.unchanged = (context.unchanged or 0) + 1
		return
	elseif (code == 200) then
		local info = textutils.unserializeJSON(data)

		if (info.type == 'directory') then
			if (fs.isDir(file)) then
				if (not flagForce and not flagSync) then
					print('Directory already exists: ' .. file)
					print('Merge? (y/N)')
					if (read() ~= 'y') then
						return
					end
				end
				context.mergedDirectories = (context.mergedDirectories or 0) + 1
			else
				context.createdDirectories = (context.createdDirectories or 0) + 1
			end

			fs.makeDir(file)

			local existingList = fs.list(file)
			local existingTable = {}

			for _, name in ipairs(existingList) do
				existingTable[name] = 'delete'
			end

			for index, subfileInfo in pairs(info.entries) do
				if (subfileInfo.type == 'file') then
					local subfilePath = fs.combine(file, subfileInfo.name)
					local md = getMetaData(subfilePath)

					if (md == nil or md.mtime ~= subfileInfo.mtime) then
						existingTable[subfileInfo.name] = 'download'
					else
						existingTable[subfileInfo.name] = 'unchanged'
					end
				else
					existingTable[subfileInfo.name] = 'download'
				end
			end

			for subfile, action in pairs(existingTable) do
				local subfilePath = fs.combine(file, subfile)

				if (action == 'delete') then
					if (flagSync) then
						if (not flagNoBackup) then
							local backup = subfilePath .. '.bak'
							if (fs.exists(backup)) then
								fs.delete(backup)
							end
							fs.move(subfilePath, backup)
							if (not flagQuiet) then
								print('  backup: ' .. backup)
							end
							context.backups = (context.backups or 0) + 1
						else
							fs.delete(subfilePath)
							if (not flagQuiet) then
								print('  delete: ' .. subfilePath)
							end

							context.deleted = (context.deleted or 0) + 1
						end
					end
				elseif (action == 'unchanged') then
					context.unchanged = (context.unchanged or 0) + 1
				elseif (action == 'download') then
					download(subfilePath, context, flagForce, flagNoBackup, flagSync, flagQuiet)
				end
			end
		elseif (info.type == 'file') then
			if fs.exists(file) then
				if (not flagForce) then
					print('File already exists: ' .. file)
					print('Overwrite? (y/N)')
					if (read() ~= 'y') then
						return
					end
				end
				if not flagNoBackup then
					if (fs.exists(file .. '.bak')) then
						fs.delete(file .. '.bak')
					end
					fs.move(file, file .. '.bak')
					if (not flagQuiet) then
						print('  backup: ' .. file .. '.bak')
					end
					context.backups = (context.backups or 0) + 1
				end
				context.replacedFiles = (context.replacedFiles or 0) + 1
				if (not flagQuiet) then
					print(' replace: ' .. file)
				end
			else
				context.createdFiles = (context.createdFiles or 0) + 1
				if (not flagQuiet) then
					print('download: ' .. file)
				end
			end

			local f = fs.open(file, 'w')
			f.write(info.content)
			f.close()
			setMetaData(
				file,
				{
					mtime = info.mtime
				}
			)
		end
	else
		print('Error: ' .. data)
	end
end

local function printFile(file)
	local success, data = get(file)

	if (success) then
		print(data)
	else
		print('Error: ' .. data)
	end
end

if (shell) then
	local args = {...}

	local file = nil
	local flagPrint = false
	local flagForce = false
	local flagNoBackup = true
	local flagSync = false
	local flagMd5 = false
	local flagQuiet = false

	while (#args > 0) do
		local arg = table.remove(args, 1)

		if (arg == '-p') then
			flagPrint = true
		elseif (arg == '-f') then
			flagForce = true
		elseif (arg == '-b') then
			flagNoBackup = false
		elseif (arg == '-s') then
			flagSync = false
			flagForce = true
		elseif (arg == '-h') then
			flagMd5 = true
		elseif (arg == '-q') then
			flagQuiet = true
		elseif (arg:sub(1, 1) == '-') then
			print('Unknown option: ' .. arg)
			return
		else
			if (file ~= nil) then
				print('Only one file can be specified')
				return
			end
			file = arg
		end
	end

	if (not flagQuiet) then
		print('tap version: ' .. version)
		print()
	end

	if file ~= nil then
		if (flagMd5) then
			print('MD5: ' .. getFileMd5(file))
		elseif (flagPrint) then
			printFile(file)
		else
			local context = {}
			download(file, context, flagForce, flagNoBackup, flagSync, flagQuiet)
			if (not flagQuiet) then
				for stat, count in pairs(context) do
					print(stat .. ': ' .. count)
				end
			end
		end
	end
else
	return {
		version = version,
		download = function(file, options)
			local context = options.context or {}
			local flagForce = options.force or options.sync or false
			local flagNoBackup = options.noBackup or true
			local flagSync = options.sync or false
			local flagMd5 = options.md5 or false
			local flagQuiet = options.quiet or false

			download(file, context, flagForce, flagNoBackup, flagSync, flagQuiet)
		end
	}
end
