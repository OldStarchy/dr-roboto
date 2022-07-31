includeOnce 'lib/Cli'

local version = '0.0.1'

--[=[
	chest api

	size()
	list()
	getItemDetail(slot)
	getItemLimit(slot)
	pushItems(toName, fromSlot [, limit [, toSlot]])
	pullItems(fromName, fromSlot [, limit [, toSlot]])
]=]

local data = hardTable('data/chester')

if (data.labels == nil) then
	data.labels = {}
end

local function setLabel(chestName, label)
	data.labels[label] = chestName
end

local function getLabel(chestName)
	for label, name in pairs(hardTableExport(data.labels)) do
		if (name == chestName) then
			return label
		end
	end
	return nil
end

local function findConnectedChests(requiredType)
	local chests = {}
	requiredType = requiredType or 'inventory'
	for _, chest in pairs(peripheral.getNames()) do
		if (peripheral.hasType(hest, requiredType)) then
			table.insert(chests, chest)
		end
	end

	return chests
end

local function resolveLabel(chestName)
	if (data.labels[chestName]) then
		return data.labels[chestName]
	end

	if (chestName == '$shulker') then
		local chests = findConnectedChests('minecraft:shulker_box')
		if (#chests > 0) then
			return chests[1]
		end
	end

	return chestName
end

local function resolveLabels(chestNames)
	local result = {}

	for i, chestName in ipairs(chestNames) do
		result[i] = resolveLabel(chestName)
	end

	return result
end

local function getItemsInChest(chestName)
	local chestName = resolveLabel(chestName)

	local items = {}
	local list = peripheral.call(chestName, 'list')
	for _, item in pairs(list) do
		if (items[item.name] == nil) then
			items[item.name] = 0
		end
		items[item.name] = item.count
	end

	return items
end

local function getItemsInChests(chestNames)
	local items = {}

	for _, chestName in ipairs(chestNames) do
		local content = getItemsInChest(chestName)

		for itemName, itemCount in pairs(content) do
			if (items[itemName] == nil) then
				items[itemName] = 0
			end
			items[itemName] = items[itemName] + itemCount
		end
	end

	return items
end

local function getItemsInStorage()
	local chests = findConnectedChests()
	local items = getItemsInChests(chests)

	return items
end

local function moveItemsFromChestIntoChests(fromChest, toChests)
	local fromChest = resolveLabel(fromChest)
	local toChests = resolveLabels(toChests)

	local size = peripheral.call(fromChest, 'size')

	local result = {}

	for slot = 1, size do
		local stack = peripheral.call(fromChest, 'getItemDetail', slot)

		if (stack ~= nil) then
			local remaining = stack.count

			for _, toChest in ipairs(toChests) do
				local moved = peripheral.call(fromChest, 'pushItems', toChest, slot)
				remaining = remaining - moved

				if (moved > 0) then
					print('Moved ' .. moved .. ' ' .. stack.name .. ' from ' .. fromChest .. ' to ' .. toChest)
				end

				if (remaining == 0) then
					break
				end
			end

			if (remaining > 0) then
				result[stack.name] = (result[stack.name] or 0) + remaining
			end
		end
	end

	return #result == 0, result
end

local function moveItemsFromChestIntoStorage(chestName)
	local allChests = findConnectedChests()
	local storageChests = {}

	for _, chest in pairs(allChests) do
		if (chest ~= chestName) then
			table.insert(storageChests, chest)
		end
	end

	local result = moveItemsFromChestIntoChests(chestName, storageChests)
	return result
end

local function findAndMoveAllItemToChest(itemName, toChest)
	local toChest = resolveLabel(toChest)
	local allChests = findConnectedChests()
	local fromChests = {}

	for _, chest in pairs(allChests) do
		if (chest ~= toChest) then
			table.insert(fromChests, chest)
		end
	end

	local movedAny = false

	for _, fromChest in ipairs(fromChests) do
		local chestItems = getItemsInChest(fromChest)
		local itemCount = chestItems[itemName] or 0

		if (itemCount > 0) then
			local size = peripheral.call(fromChest, 'size')

			for slot = 1, size do
				local stack = peripheral.call(fromChest, 'getItemDetail', slot)
				if (stack ~= nil and stack.name == itemName) then
					local moved = peripheral.call(fromChest, 'pushItems', toChest, slot)

					if (moved == 0) then
						return movedAny
					else
						print('Moved ' .. moved .. ' ' .. itemName .. ' from ' .. fromChest .. ' to ' .. toChest)
						movedAny = true
					end
				end
			end
		end
	end

	return movedAny
end

local cli = Cli('chester', 'A large storage chest management tool', 'help')

cli:addAction(
	'help',
	function()
		cli:printUsage()
	end,
	nil,
	'Shows this help text'
)

cli:addAction(
	'version',
	function()
		print('chester version: ' .. version)
	end,
	nil,
	'Shows the version of chester'
)

cli:addAction(
	'list',
	function(chestName)
		local chests = {}
		if (chestName) then
			table.insert(chests, resolveLabel(chestName))
		else
			chests = findConnectedChests()
		end

		print('looking in ' .. #chests .. ' chests')
		local items = getItemsInChests(chests)

		local itemNames = {}
		for itemName, itemCount in pairs(items) do
			table.insert(itemNames, itemName)
		end
		table.sort(itemNames)
		for _, itemName in ipairs(itemNames) do
			print(itemName .. ': ' .. items[itemName])
		end
	end,
	{'[chestName]'},
	'Lists the contents of a chest'
)

cli:addAction(
	'setLabel',
	function(chestName, label)
		setLabel(chestName, label)
	end,
	{'chestName', 'label'},
	'Sets a label for a chest'
)

cli:addAction(
	'listLabels',
	function()
		for chestName, label in pairs(hardTableExport(data.labels)) do
			print(chestName .. ': ' .. label)
		end
	end,
	nil,
	'Lists all labels'
)

cli:addAction(
	'deposit',
	function(chestName)
		chestName = chestName or 'default'
		local result, items = moveItemsFromChestIntoStorage(chestName)

		if (result) then
			print('deposited items')
		else
			print('failed to deposit ' .. #items .. ' items')
		end
	end,
	{'[chestName]'},
	'Deposits all items from a chest into the storage chest'
)

cli:addAction(
	'withdraw',
	function(itemName, toChest)
		toChest = toChest or 'default'

		local result = findAndMoveAllItemToChest(itemName, toChest)

		if (result) then
			print('withdrew items')
		else
			print('failed to withdraw items')
		end
	end,
	{'itemName', '[toChest]'},
	'Withdraws all items of a given name from the storage into a chest'
)

cli:addAction(
	'show',
	function(typeFilter)
		local chests = findConnectedChests()

		table.sort(chests)

		for _, chest in ipairs(chests) do
			local types = {peripheral.getType(chest)}

			local isType = true
			if (typeFilter) then
				isType = peripheral.hasType(chest, typeFilter)
			end

			if (isType) then
				local label = getLabel(chest)
				local items = getItemsInChest(chest)
				local types = table.concat(types, ', ')
				local isEmpty = #items == 0

				print(chest .. (label and ' (' .. label .. ')' or '') .. ':')
				print(' Items: ' .. (isEmpty and 'empty' or #items))
				print(' Types: ' .. types)
			end
		end
	end,
	{'[type]'},
	'Shows all chests of a given type'
)

cli:run(...)
