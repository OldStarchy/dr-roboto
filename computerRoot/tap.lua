local version = '0.1.1'
local protocol = 'http'
local domain = 'sorokin.id.au'
local headers = {
	['x-tap'] = version
}

local function get(file)
	local url = protocol .. '://' .. fs.combine(domain, file)

	print('GET ' .. url)

	local response, errorMessage, badResponse = http.get(url, headers)

	if response then
		local data = response.readAll()

		return true, data
	else
		return false, errorMessage, badResponse.readAll()
	end
end

local function download(file, flagForce, flagNoBackup)
	local success, data = get(file)

	if (success) then
		local info = textutils.unserializeJSON(data)

		if (info.type == 'directory') then
			if (fs.isDir(file)) then
				if (not flagForce) then
					print('Directory already exists: ' .. file)
					print('Merge? (y/N)')
					if (read() ~= 'y') then
						return
					end
				end
			end

			fs.makeDir(file)
			for index, subfile in pairs(info.entries) do
				download(fs.combine(file, subfile), flagForce, flagNoBackup)
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
					print('Backup created: ' .. file .. '.bak')
				end
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
		download(file, flagForce, flagNoBackup)
	end
end
