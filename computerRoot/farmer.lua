-- Farm Manager
-- @author OldStarchy

--TODO: this is not actually a json file
local saveFile = '.farms.json'

--TODO: rename "name" to "blockName"
--TODO: rename "seeds" to "seedName"
local product = {
	['minecraft:wheat'] = {
		name = 'minecraft:wheat',
		seeds = 'minecraft:wheat_seeds',
		isReady = function(block)
			return block.state.age == 7
		end
	},
	['minecraft:carrots'] = {
		name = 'minecraft:carrots',
		seeds = 'minecraft:carrot',
		isReady = function(block)
			return block.state.age == 7
		end
	},
	['minecraft:potatoes'] = {
		name = 'minecraft:potatoes',
		seeds = 'minecraft:potato',
		isReady = function(block)
			return block.state.age == 7
		end
	},
	['minecraft:beetroot'] = {
		name = 'minecraft:beetroots',
		seeds = 'minecraft:beetroot_seeds',
		isReady = function(block)
			return block.state.age == 3
		end
	},
	['minecraft:pumpkin'] = {
		name = 'minecraft:pumpkin',
		seeds = nil,
		isReady = function(block)
			return true
		end
	}
}

local farms = {}

local storageLocations = {
	front = 'front',
	up = 'up',
	down = 'down'
}

---@param file string
local function loadFarms(file)
	--TODO: change farms to data.farms (and add data and move .composter out of farms)
	farms = fs.readTableFromFile(file)
end

---@param file string
local function saveFarms(file)
	fs.writeTableToFile(file, farms)
end

local function addFarm(product, pos)
	local farm = {
		product = product.name,
		pos = pos
	}
	table.insert(farms, farm)
	saveFarms(saveFile)
end

local function _harvestFarm(farm)
	if (turtle.getFuelLevel() < 150) then
		print('Not enough fuel')
		return false
	end

	if (farm.storage == nil) then
		print('Farm has no storage location')
		print('Add a location by moving to the location and typing "farmer setStorage <farmId> <side>"')
		return
	end

	-- I considered collecting seeds from storage first, but taking a specific item from a chest is very hard

	local farmPos = farm.pos
	local product = product[farm.product]

	-- the farm is a 9x9 square. move to each position on the farm and check isReady. If so, digDown, then select seeds and placeDown.

	for x = -4, 4 do
		-- go back and fourth
		local dir = x % 2 == 0 and 1 or -1

		for z = -4 * dir, 4 * dir, dir do
			if (x == 0 and z == 0) then
				-- skip the water in the center
			else
				nav:pathTo(Position(farmPos.x + x, farmPos.y, farmPos.z + z))
				local succ, block = turtle.inspectDown()

				if (succ) then
					if (block.name == product.name) then
						if (product.isReady(block)) then
							turtle.digDown()
							if (product.seeds ~= nil and inv:select(product.seeds)) then
								turtle.placeDown()
							end
						end
					end
				else
					if (product.seeds ~= nil and inv:select(product.seeds)) then
						turtle.placeDown()
					end
				end
			end
		end
	end

	local storagePos = farm.storage.pos

	nav:pathTo(storagePos)
	mov:face(storagePos.direction)

	for i = 1, 16 do
		if (turtle.getItemCount(i) > 0) then
			if (inv:select(i)) then
				if (farm.storage.side == 'front') then
					turtle.drop()
				elseif (farm.storage.side == 'up') then
					turtle.dropUp()
				elseif (farm.storage.side == 'down') then
					turtle.dropDown()
				end
			end
		end
	end

	local hasLeftoverItems = false
	for i = 1, 16 do
		if (turtle.getItemCount(i) > 0) then
			hasLeftoverItems = true
		end
	end

	if (hasLeftoverItems) then
		if (farms.compost) then
			nav:pathTo(farms.compost.pos)
			mov:face(farms.compost.pos.direction)

			for i = 1, 16 do
				if (turtle.getItemCount(i) > 0) then
					if (inv:select(i)) then
						if (farms.compost.side == 'front') then
							turtle.drop()
						elseif (farms.compost.side == 'up') then
							turtle.dropUp()
						elseif (farms.compost.side == 'down') then
							turtle.dropDown()
						end
					end
				end
			end
		else
			print('No compost location set')
			print('Add a location by moving to the location and typing "farmer setCompost <side>"')
		end
	end
end

local function harvestFarms(farms)
	mov:push(false, false, true)

	for _, farm in ipairs(farms) do
		_harvestFarm(farm)
	end

	nav:pathTo(Position())
	mov:face(0)
	mov:pop()
end

local function run(...)
	local args = {...}

	if (#args == 0) then
		print('Usage: farmer <command> [args]')
		print('Commands:')
		print('  list')
		print('  add <product>')
		-- print('  add <name> <x> <y> <z>')
		print('  remove <farmId>')
		print('  goto <farmId> [storage]')
		print('  goto compost')
		print('  setStorage <farmId> <side>') --side can be front, up, or down
		print('  clearStorage <farmId>')
		print('  setCompost <side>')
		print('  clearCompost')
		print('  harvest <farmId> [...<farmId>]')
		print('  harvest <product>')
		print('  harvest all')
		return
	end

	local command = args[1]

	if (fs.exists(saveFile)) then
		print('Loading farms from ' .. saveFile)
		loadFarms(saveFile)
	end

	if (command == 'list') then
		for id, farm in ipairs(farms) do
			print(id .. ': ' .. farm.product .. ' (' .. farm.pos.x .. ',' .. farm.pos.y .. ',' .. farm.pos.z .. ')')
		end
		return
	end

	if (command == 'add') then
		if (#args < 2) then
			print('Usage: farmer add <product>')
			return
		end
		local productName = args[2]
		if (not product[productName]) then
			print('Invalid product')
			return
		end

		local pos = nav:getPosition()
		local product = product[productName]

		print('Adding farm for ' .. product.name .. ' at ' .. pos.x .. ' ' .. pos.y .. ' ' .. pos.z)

		addFarm(product, pos)
		return
	end

	if (command == 'remove') then
		if (#args < 2) then
			print('Usage: farmer remove <id>')
			return
		end
		local id = tonumber(args[2])
		if (not id) then
			print('Invalid id')
			return
		end
		if (not farms[id]) then
			print('Invalid id')
			return
		end
		table.remove(farms, id)
		saveFarms(saveFile)
		return
	end

	if (command == 'goto') then
		if (#args < 2) then
			print('Usage:')
			print('  goto <id> [storage]')
			print('  goto compost')
			return
		end

		local destination = args[2]
		if (destination == 'compost') then
			if (farms.compost) then
				nav:pathTo(farms.compost.pos)
				mov:face(farms.compost.pos.direction)
			else
				print('No compost location set')
			end
			return
		end

		local id = tonumber(args[2])
		if (not id) then
			print('Invalid id')
			return
		end
		if (not farms[id]) then
			print('Invalid id')
			return
		end
		local farm = farms[id]
		local storage = false
		if (#args > 2) then
			storage = args[3] == 'storage'
		end

		if (storage) then
			nav:pathTo(farm.storage.pos)
			mov:face(farm.storage.pos.direction)
		else
			nav:pathTo(farm.pos)
		end
		return
	end

	if (command == 'setStorage') then
		if (#args < 3) then
			print('Usage: farmer setStorage <farmId> <side>')
			return
		end
		local id = tonumber(args[2])
		if (not id) then
			print('Invalid id')
			return
		end
		if (not farms[id]) then
			print('Invalid id')
			return
		end
		local side = args[3]
		if (not storageLocations[side]) then
			print('Invalid side')
			return
		end
		farms[id].storage = {
			pos = nav:getPosition(),
			side = storageLocations[side]
		}
		saveFarms(saveFile)
		return
	end

	if (command == 'clearStorage') then
		if (#args < 2) then
			print('Usage: farmer clearStorage <farmId>')
			return
		end
		local id = tonumber(args[2])
		if (not id) then
			print('Invalid id')
			return
		end
		if (not farms[id]) then
			print('Invalid id')
			return
		end
		farms[id].storage = nil
		saveFarms(saveFile)
		return
	end

	if (command == 'setCompost') then
		local position = nav:getPosition()
		local side = args[2]
		if (not side) then
			print('Usage: farmer setCompost <side>')
			return
		end
		farms.compost = {
			pos = position,
			side = side
		}
		saveFarms(saveFile)
		return
	end

	if (command == 'clearCompost') then
		farms.compost = nil
		saveFarms(saveFile)
		return
	end

	if (command == 'harvest') then
		if (#args < 2) then
			print('Usage:')
			print('  harvest <farmId> [...<farmId>]')
			print('  harvest <product>')
			print('  harvest all')
			return
		end
		local nextArg = args[2]

		local _farms = {}

		if (nextArg == 'all') then
			for id, farm in ipairs(farms) do
				_farms[id] = farm
			end
		else
			while (#args > 1) do
				local idOrProduct = table.remove(args, 2)
				local id = tonumber(idOrProduct)
				if (not id) then
					local any = false
					for _id, _farm in ipairs(farms) do
						if (_farm.product == idOrProduct) then
							_farms[_id] = _farm
							any = true
						end
					end
					if (not any) then
						print('No farm with product ' .. idOrProduct)
						return
					end
				elseif (not farms[id]) then
					print('Invalid id')
					return
				else
					_farms[id] = farms[id]
				end
			end
		end

		harvestFarms(tableValues(_farms))
	end
end

run(...)
