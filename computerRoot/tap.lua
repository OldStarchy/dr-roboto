local version = '0.3.0'
local headers = {
	['x-tap'] = version
}

-- these get set by the server
local defaultProto = '%%PUBLIC_PROTO%%'
local defaultDomain = '%%PUBLIC_DOMAIN%%'

local metaDataFile = '.tap/metaData.tbl'
local repositoriesFile = '.tap/repositories.tbl'

local currentRepository = nil

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

local function loadRepositories()
	if (fs.exists(repositoriesFile)) then
		return fileToTable(repositoriesFile)
	else
		return {}
	end
end

local function saveRepositories(repositories)
	tableToFile(repositories, repositoriesFile)
end

local function addRepository(name, protocol, domain, priority)
	local repositories = loadRepositories()
	repositories[name] = {
		protocol = protocol,
		domain = domain,
		priority = priority
	}
	saveRepositories(repositories)
end

local function addDefaultRepo()
	local repos = loadRepositories()
	local repoCount = countKeys(repos)

	if (repoCount == 0) then
		if (stringutil.startsWith(defaultProto, '%%PUBLIC')) then
			error('No default repository set, use "tap --addRepository" to add one')
		end
		addRepository('default', defaultProto, defaultDomain, 0)
	end
end

addDefaultRepo()

local function removeRepository(name)
	local repositories = loadRepositories()
	repositories[name] = nil
	saveRepositories(repositories)
end

local function getRepositoryPathForFile(repository, file)
	return repository.protocol .. '://' .. fs.combine(repository.domain, file)
end

local function getSortedRepositories()
	local repositories = loadRepositories()
	local sortedRepositories = {}
	for name, repository in pairs(repositories) do
		table.insert(
			sortedRepositories,
			{
				name = name,
				protocol = repository.protocol,
				domain = repository.domain,
				priority = repository.priority
			}
		)
	end
	table.sort(
		sortedRepositories,
		function(a, b)
			return a.priority < b.priority
		end
	)
	return sortedRepositories
end

local function ask(question)
	print(question)
	return read()
end

local function askWithDefault(question, def)
	print(question .. ' [' .. def .. ']')
	local answer = read()
	if (answer == '') then
		return def
	else
		return answer
	end
end

local function promptToCreateRepository()
	local correct = false

	local name, protocol, domain, priority

	while (not correct) do
		name = askWithDefault('Name', 'default')
		protocol = askWithDefault('Protocol', 'https')
		domain = ask('Domain')
		priority = tonumber(askWithDefault('Priority (asc)', '1'))
		if (priority == nil) then
			print 'Priority must be a number'
			priority = tonumber(askWithDefault('Priority', '1'))
			if (priority == nil) then
				print('you fail start again')
				error('incompetence')
			end
		end

		print('Adding repository...')
		print('Name: ' .. name)
		print('Url: ' .. protocol .. '://' .. domain)
		print('Priority: ' .. priority)
		print('Is this correct? [Y/n]')
		local answer = read()
		if (answer == '' or answer == 'y' or answer == 'Y') then
			correct = true
		end
	end

	addRepository(name, protocol, domain, priority)
	return true
end

local function promptToRemoveRepository()
	local repositories = loadRepositories()
	if (next(repositories) == nil) then
		print('No repositories found.')
		return
	end

	print('Repositories:')
	for name, repository in pairs(repositories) do
		print('  ' .. name .. ' - ' .. repository.protocol .. '://' .. repository.domain)
	end

	print('Which repository would you like to remove?')
	local name = read()
	if (name == '') then
		return
	end

	removeRepository(name)
end

local function listRepositories()
	local repositories = getSortedRepositories()
	if (next(repositories) == nil) then
		print('No repositories found.')
		return
	end

	for _, repository in pairs(repositories) do
		print(string.format('%s (%d): %s', repository.name, repository.priority, getRepositoryPathForFile(repository, '')))
	end
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

local function getFromRepository(repository, file, hash)
	local url = getRepositoryPathForFile(repository, file)

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

local function get(file, hash, flagQuiet)
	local sortedRepositories = getSortedRepositories()
	if (currentRepository) then
		table.insert(sortedRepositories, 1, currentRepository)
	end

	if (#sortedRepositories == 0) then
		print('No repositories found, you must create one now')
		if (promptToCreateRepository()) then
			sortedRepositories = getSortedRepositories()
		else
			error('No repositories to download file')
		end
	end

	local responseCode, data, errorMessage, badResponse
	for _, repository in ipairs(sortedRepositories) do
		responseCode, data, errorMessage, badResponse = getFromRepository(repository, file, hash)

		if (responseCode == 200 or responseCode == 304) then
			if (not currentRepository) then
				if (not flagQuiet) then
					print('Using repository "' .. repository.name .. '"')
				end
				currentRepository = repository
			end
			break
		end
	end

	return responseCode, data, errorMessage, badResponse
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

	local code, data = get(file, hash, flagQuiet)

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

		if (arg == '--addRepository') then
			promptToCreateRepository()
			return
		elseif (arg == '--removeRepository') then
			promptToRemoveRepository()
			return
		elseif (arg == '--listRepositories') then
			listRepositories()
			return
		elseif (arg == '-p') then
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
		end,
		addRepository = addRepository,
		removeRepository = removeRepository,
		getRepositories = function()
			return loadRepositories()
		end
	}
end
