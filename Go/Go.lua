Go = Class()
function Go:constructor()
	self.actions = {}
	self.tokens = {}
	self.parenthesesDepth = 0
	self.actionKeys = {}
	self.factionKeys = {}
	self.head = 1
	self.inp = nil
	self.lim = 0
	self.speratorCharacter = '%'
end

function Go:inputError(err, pos)
	pos = pos or self.head
	print(err)
	print(self.inp)
	local s = ''
	for i = 2, pos do
		s = s .. ' '
	end
	print(s .. '^')
	error(err, 4)
end

function Go:alias(a, factory)
	if type(factory) ~= 'function' then
		error('Must specify action factory', 3)
	end

	if type(a) == 'table' then
		table.insert(self.factionKeys, a)
		for _, v in pairs(a) do
			self:alias(v, factory)
		end
		return
	end

	self.actions[a] = factory
end

function Go:addToken(t, isMod)
	if (type(t) == 'table' and not isMod) then
		table.insert(self.tokens, t)
		return
	end

	if type(t) == 'function' and not isMod then
		table.insert(self.tokens, t())
		return
	end

	if type(t) == 'string' and not isMod then
		if t == '(' then
			table.insert(self.tokens, t)
			self.parenthesesDepth = self.parenthesesDepth + 1
			return
		end

		if t == ')' then
			self.parenthesesDepth = self.parenthesesDepth - 1
			local i
			for i = #self.tokens, 1, -1 do
				if self.tokens[i] == '(' then
					local seq = {}
					while #self.tokens > i do
						table.insert(seq, table.remove(self.tokens, i + 1))
					end
					self.tokens[i] = Sequence.new(seq)
					return
				end
			end
			self:inputError('Unmatched parentheses')
		end
	end

	if #self.tokens == 0 then
		self:inputError('Nothing to modify')
	end

	if self.tokens[#self.tokens].mod == nil then
		self:inputError("Can't use modifiers here")
	end

	if not self.tokens[#self.tokens]:mod(t) then
		self:inputError('Invalid modifier')
	end
end

function Go:take()
	local char = self.inp:sub(self.head, self.head)
	if (char == self.speratorCharacter) then
		self.head = self.head + 1
		return true
	end

	if (char == "'") then
		local st = self.inp:sub(self.head + 1)
		local otherEnd = string.find(st, char, 1, true)
		if (otherEnd == nil) then
			self:inputError('Unterminated string', self.head + 1)
		end

		self:addToken({str = string.gsub(st:sub(1, otherEnd - 1), '%' .. self.speratorCharacter, ' ')}, true)

		self.head = self.head + otherEnd + 1
		return true
	end

	-- Need to check for - before tonumber, because tonumber will think its a number
	if char == '-' then
		self:addToken('-')
		self.head = self.head + 1
		return true
	end

	for _, k in pairs(self.actionKeys) do
		if self.inp:sub(self.head, self.head + #k - 1) == k then
			self:addToken(self.actions[k])
			self.head = self.head + #k
			return true
		end
	end

	local c = 0
	while (self.head + c <= self.lim) and tonumber(self.inp:sub(self.head, self.head + c)) ~= nil do
		c = c + 1
	end
	c = c - 1
	if tonumber(self.inp:sub(self.head, self.head + c)) ~= nil then
		self:addToken(tonumber(self.inp:sub(self.head, self.head + c)))
		self.head = self.head + c + 1
		return true
	end

	self:addToken(char)
	self.head = self.head + 1
	return true
end

function Go:saveCommandToHistory(input)
	--TODO: save go commands to history
end

function Go:execute(input)
	self:saveCommandToHistory(input)
	self.inp = input
	self.lim = #input

	--Collect all the actionKeys (f, forward, b, back etc) defined
	for i, _ in pairs(self.actions) do
		table.insert(self.actionKeys, i)
	end

	--Sort actionKeys largest to smallest for better recognition
	table.sort(
		self.actionKeys,
		(function(a, b)
			if #a > #b then
				return true
			end
			return false
		end)
	)

	while self.head < self.lim + 1 and self:take() do
	end

	if (self.parenthesesDepth > 0) then
		self:inputError('Unmatched parentheses', string.find(self.inp, '(', 1, true))
	end

	local all = self.tokens
	if (#all > 1) then
		all = Sequence.new(all)
	else
		all = self.tokens[1]
	end

	all:run(ActionInvocation.new())
end
