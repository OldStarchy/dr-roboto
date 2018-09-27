function hardTable(filename)
	if (ends_with(filename, '.lua')) then
		error('Creating a hardTable with a .lua extension is probably an error', 2)
	end

	local data = {}

	local function save()
		local f = fs.open(filename, 'w')
		print(f)
		f.write(textutils.serialise(data))
		f.close()
	end

	local function load()
		local f = fs.open(filename, 'r')

		if (f) then
			local tbl = textutils.deserialize(f.readAll())
			f.close()

			if (tbl == nil) then
				-- String could not be parsed
				return false
			else
				data = tbl
				return true
			end
		end

		--File does not exist (can be created)
		return true
	end

	local metaTable
	metaTable = {
		__index = function(t, k)
			load()
			return data[k]
		end,
		__newindex = function(t, k, v)
			data[k] = v
			save()
		end
	}

	if (not load()) then
		error('Hard table could not load data from ' .. filename, 2)
	end

	local proxy = {}
	setmetatable(proxy, metaTable)
	return proxy
end
