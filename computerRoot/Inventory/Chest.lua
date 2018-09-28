local Chest = Class()

function Chest:constructor(name, isDouble)
	self.name = name
	chest.isDouble = not (not isDouble)
end

function Chest:size()
	return self.isDouble and 54 or 27
end

function Chest:printName()
	print(self.name)
end

function Chest:isEmpty()
	if
		(self:getFirst(
			function(self, slot)
				return self:getItemCount(slot) ~= 0
			end
		))
	 then
		return false
	end

	return true
end

function Chest:getFirst(delegate)
	for i = 1, self.size do
		if delegate(self, i) then
			return i
		end
	end
	return nil
end

function Chest:getNext(delegate, last)
	for i = last + 1, self.size do
		if delegate(self, i) then
			return i
		end
	end
	return nil
end

function Chest:getLast(delegate) --GOOD
	for i = self.size, 1, -1 do
		if delegate(self, i) then
			return i
		end
	end
	return nil
end

function Chest:getPrevious(delegate, last) --GOOD
	last = last or self.size + 1
	for i = last - 1, 1, -1 do
		if delegate(self, i) then
			return i
		end
	end
	return nil
end

function Chest:getItemAt(slot)
	if self[slot] == nil then
		return nil
	else
		return self[slot].name
	end
end

function Chest:getItemCount(slot)
	return ((self[slot] and self[slot].count) or 0)
end

function Chest:getItemSpace(slot, item)
	return inv.stackSize(self:getItemAt(slot) or item) - self:getItemCount(slot)
end

local function delHasFree(item)
	return function(self, slot)
		if self[slot] == nil then
			return true
		elseif self:getItemAt(slot) == item then
			return self:getItemSpace(slot) > 0
		else
			return false
		end
	end
end

function Chest:firstAvailable(item)
	return self:getFirst(delHasFree(item))
end

function Chest:nextAvailable(item, from)
	return self:getNext(delHasFree(item), from)
end

function Chest:nextAvailable(item, from)
	for i = from + 1, self.size do
		if self[i] == nil then
			return i, inv.stackSize(item)
		elseif self[i].name == item then
			if (inv.stackSize(item) - self[i].count > 0) then
				return i, inv.stackSize(item) - self[i].count
			end
		end
	end
	return nil
end

function Chest:getTotalSpaceFor(item)
	local count = 0
	local i = self:firstAvailable(item)
	local spare = self:getItemSpace(i)
	while i ~= nil do
		count = count + spare
		i = self:nextAvailable(item, i)
		spare = self:getItemSpace(i)
	end

	return count
end

local function slot(item, count)
	local s = {}
	s.name = item
	if type(count) == 'number' then
		s.count = count
	else
		s.count = 0
	end
	return s
end

function Chest:canPush(item, count)
	local c = self:getTotalSpaceFor(item) - count
	if c >= 0 then
		return true
	else
		return false, -c
	end
end

function Chest:push(item, count)
	if (self:getTotalSpaceFor(item) < count) then
		return false, 'Not enough space for items'
	end
	local i = self:firstAvailable(item)
	spare = self:getItemSpace(i, item)
	local moved = 0
	while (i ~= nil and moved < count) do
		if spare > (count - moved) then
			spare = (count - moved)
		end
		if (self[i] == nil) then
			self[i] = slot(item, spare)
		else
			self[i].count = self[i].count + spare
		end
		moved = moved + spare

		i = self:nextAvailable(item, i)
		spare = self:getItemSpace(i, item)
	end
	if (moved < count) then
		return false, 'Not enough space for items (some moved)'
	end
	return true
end

function Chest:has(item)
	for i = 1, self.size do
		if self[i] then
			if self[i].name == item then
				return true
			end
		end
	end
	return false
end

function Chest:peek()
	for i = 1, self.size do
		if self[i] then
			return self[i].name, self[i].count
		end
	end
end

function Chest:pop()
	local r = nil
	for i = 1, self.size do
		if self[i] then
			r = self[i]
			self[i] = nil
			break
		end
	end
	return r.name, r.count
end

function Chest:print(start)
	start = start or 1
	local lim = self.size
	if lim > start + 10 then
		lim = start + 10
	end
	for i = start, lim do
		if self[i] then
			print(i .. ': ' .. self[i].count .. ' ' .. self[i].name)
		end
	end
end

function Chest:save(filename)
	local file = fs.open(filename, 'w')
	file:write(textutils.serialize(self))
	file:close()
end

--[=[

--TODO: make proper serialization / deserialization for class objects
function load(filename)
	local file = fs.open(filename, 'r')
	local ch = textutils.unserialize(file:read())
	file:close()

	return setmetatable(ch, Chest)
end

function index(side, name, isDouble)
	if not side then
		side = ''
	end
	debugger.assert(side == '' or side == 'Up' or side == 'Down')
	if not inv.push('minecraft:chest') then
		inv.pop()
		return nil, 'Need a chest'
	end

	if turtle.getItemCount() ~= 1 then
		if not inv.push() then
			inv.pop()
			inv.pop()
			return nil, 'Need an empty slot to cycle items'
		end
		inv.pop()
	end

	local chestOptions = {Up = true, Down = true, [''] = true}
	chestOptions[side] = nil
	local chestpos = nil
	for i, v in pairs(chestOptions) do
		if not turtle['detect' .. i]() then
			chestPos = i
			break
		end
	end

	if not chestPos then
		return nil, 'No room to place chest'
	end

	turtle['place' .. chestPos]()
	inv.select()

	local function cycleOut()
		local a = turtle['suck' .. side]()
		turtle['drop' .. chestPos]()
		return a
	end

	local chest = Chest.new(name, isDouble)
	local function cycleIn()
		turtle['suck' .. chestPos]()
		local deets = turtle.getItemDetail()
		chest:push(deets.name .. tostring(deets.damage), deets.count)
		turtle['drop' .. side]()
	end

	local stacks = 0
	while cycleOut() and stacks < 27 do
		stacks = stacks + 1
	end

	for i = 1, stacks do
		cycleIn()
	end

	turtle['dig' .. chestPos]()
	return chest
end

if not inv then
	inv = {
		stackSize = function(name)
			return 64
		end,
		stack = {},
		push = function(arg)
			table.insert(inv.stack, turtle.getSelectedSlot())
			return inv.select(arg)
		end,
		pop = function()
			if #(inv.stack) == 0 then
				return
			end

			inv.select(table.remove(inv.stack))
		end,
		select = function(arg)
			local t = type(arg)
			if t == 'number' then
				return turtle.select(arg)
			elseif t == 'string' then
				return inv.selectByName(arg)
			elseif t == 'nil' then
				return inv.selectEmpty()
			end

			return false
		end,
		selectByName = function(name)
			local i
			for i = 1, 16 do
				local sd = turtle.getItemDetail(i)
				if sd then
					if sd.name == name then
						turtle.select(i)
						return true
					end
				end
			end
			return false
		end,
		selectEmpty = function()
			local i
			for i = 1, 16 do
				local sd = turtle.getItemDetail(i)
				if not sd then
					turtle.select(i)
					return true
				end
			end
			return false
		end
	}
end
]=]
