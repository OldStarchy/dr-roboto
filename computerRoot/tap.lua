local version = '0.1.2'
local protocol = 'http'
local domain = 'sorokin.id.au'
local headers = {
	['x-tap'] = version
}

local function get(file)
	local url = protocol .. '://' .. fs.combine(domain, file)

	local response, errorMessage, badResponse = http.get(url, headers)

	if response then
		local data = response.readAll()

		return true, data
	else
		return false, errorMessage, badResponse.readAll()
	end
end

local function download(file, context, flagForce, flagNoBackup, flagSync)
	local success, data = get(file)

	if (success) then
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

			for index, subfile in pairs(info.entries) do
				--TODO: compare mtime or hash
				existingTable[subfile] = 'download'
			end

			for subfile, action in pairs(existingTable) do
				local subfilePath = fs.combine(file, subfile)

				if (action == 'delete') then
					if (not flagNoBackup) then
						local backup = subfilePath .. '.bak'
						if (fs.exists(backup)) then
							fs.delete(backup)
						end
						fs.move(subfilePath, backup)
						print('  backup: ' .. backup)
						context.backups = (context.backups or 0) + 1
					else
						fs.delete(subfilePath)
						print('  delete: ' .. subfilePath)
						context.deleted = (context.deleted or 0) + 1
					end
				elseif (action == 'download') then
					download(subfilePath, context, flagForce, flagNoBackup, flagSync)
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
					print('  backup: ' .. file .. '.bak')
					context.backups = (context.backups or 0) + 1
				end
				context.replacedFiles = (context.replacedFiles or 0) + 1
				print(' replace: ' .. file)
			else
				context.createdFiles = (context.createdFiles or 0) + 1
				print('download: ' .. file)
			end

			local f = fs.open(file, 'w')
			f.write(info.content)
			f.close()
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

local args = {...}

local file = nil
local flagPrint = false
local flagForce = false
local flagNoBackup = true
local flagSync = false

print('tap version: ' .. version)
print()

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

if file ~= nil then
	if (flagPrint) then
		printFile(file)
	else
		local context = {}
		download(file, context, flagForce, flagNoBackup, flagSync)
		for stat, count in pairs(context) do
			print(stat .. ': ' .. count)
		end
	end
end
