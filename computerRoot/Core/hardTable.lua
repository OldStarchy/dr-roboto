--[[
	Creates a table that saves to disk on every write!

	usage:

	local a = hardTable('atable')
	a.b = 3
	print(a.b)
	--3
	a.c = {}
	a.c.f = 'hello'

	print(isHardTable(a))
	--true


	check atable to see whats going on.

	How it works:
	A hard table is an empty proxy table, using the __index/__newindex metamethods to read/write to/from the file and get/set values
	concequently, you can't use pairs or ipairs on a hardtable, because the table itself is always empty

	Limitations:
	you can't save functions or other hardtables as values in a hardtable.
	you can't use pairs or ipairs
]]
local function createSubtable(tbl, parent)
	local ht = {}
	ht.data = {}
	ht.proxy = {}
	ht.save = parent.save

	function ht.writeRam(k, v)
		if (type(v) == 'function') then
			error("Can't save functions to a hard table", 3)
		end

		if (type(v) == 'table') then
			if (isHardTable(v)) then
				error('Can\t save hard tables to hard tables, use hardTableExport', 3)
			end

			ht.data[k] = createSubtable(v, ht)
		else
			ht.data[k] = v
		end
	end

	function ht.__index(t, k)
		return ht.data[k]
	end

	function ht.__newindex(t, k, v)
		ht.writeRam(k, v)
		parent.save()
	end

	ht.data = {}
	for i, v in pairs(tbl) do
		ht.writeRam(i, v)
	end

	setmetatable(ht.proxy, ht)
	return ht.proxy
end

function isHardTable(tbl)
	local isHardTable = false

	pcall(
		function()
			local meta = getmetatable(tbl)
			if (meta.proxy == tbl) then
				isHardTable = true
			end
		end
	)

	return isHardTable
end

function hardTableExport(ht)
	local exp = {}

	for i, v in pairs(ht.data) do
		if (type(v) == 'table') then
			exp[i] = hardTableExport(getmetatable(v))
		else
			exp[i] = v
		end
	end

	return exp
end

function hardTable(filename)
	if (ends_with(filename, '.lua')) then
		error('Creating a hardTable with a .lua extension is probably an error', 2)
	end

	local ht = {}
	ht.data = {}
	ht.proxy = {}

	function ht.save()
		local f = fs.open(filename, 'w')

		f.write(textutils.serialise(hardTableExport(ht)))
		f.close()
	end

	function ht.load()
		local f = fs.open(filename, 'r')

		if (f) then
			local tbl = textutils.unserialize(f.readAll())
			f.close()

			if (tbl == nil) then
				-- String could not be parsed
				return false
			else
				ht.data = {}
				for i, v in pairs(tbl) do
					ht.writeRam(i, v)
				end
				return true
			end
		end

		--File does not exist (can be created)
		return true
	end

	function ht.writeRam(k, v)
		if (type(v) == 'function') then
			error("Can't save functions to a hard table", 3)
		end

		if (type(v) == 'table') then
			if (isHardTable(v)) then
				error('Can\t save hard tables to hard tables, use hardTableExport', 3)
			end
			ht.data[k] = createSubtable(v, ht)
		else
			ht.data[k] = v
		end
	end

	function ht.__index(t, k)
		ht.load()
		return ht.data[k]
	end

	function ht.__newindex(t, k, v)
		ht.writeRam(k, v)
		ht.save()
	end

	if (not ht.load()) then
		error('Hard table could not load data from ' .. filename, 2)
	end

	setmetatable(ht.proxy, ht)
	return ht.proxy
end
