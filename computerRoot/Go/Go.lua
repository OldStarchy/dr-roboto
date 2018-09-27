Go = Class()
Go.ClassName = 'Go'
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
	self.silentMode = false
	self.pauseOnNext = false
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

function Go:addToken(t, isMod, start, ed)
	if (type(start) ~= 'number') then
		start = self.head - 1
	end
	if (type(ed) ~= 'number') then
		ed = self.head - 1
	end

	if (type(t) == 'table' and not isMod) then
		-- I don't think there was ever at table token anyway
		error("Tokens can't be tables anymore")
	end

	if type(t) == 'function' and not isMod then
		local action = t()
		action.sourceMap.start = start
		action.sourceMap.ed = ed
		action.owner = self
		table.insert(self.tokens, action)
		return
	end

	if type(t) == 'string' and not isMod then
		if t == '(' then
			table.insert(
				self.tokens,
				{
					start = start,
					char = '('
				}
			)
			self.parenthesesDepth = self.parenthesesDepth + 1
			return
		end

		if t == ')' then
			self.parenthesesDepth = self.parenthesesDepth - 1
			local i
			for i = #self.tokens, 1, -1 do
				if self.tokens[i].char and self.tokens[i].char == '(' then
					local seq = {}
					while #self.tokens > i do
						table.insert(seq, table.remove(self.tokens, i + 1))
					end
					local startTok = self.tokens[i]
					self.tokens[i] = Sequence(seq)
					self.tokens[i].owner = self
					self.tokens[i].sourceMap.start = startTok.start
					self.tokens[i].sourceMap.ed = ed
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
	else
		self.tokens[#self.tokens].sourceMap.ed = ed
	end
end

--Reads the next character, number, or string from the input
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

function Go:printSourceMap(action)
	local i = 0
	local width = term.getSize()
	local blankLine = string.rep(' ', width)

	local lines = 0
	local printedPointer = false
	while (i < #self.inputClean) do
		lines = lines + 1
		print(self.inputClean:sub(i + 1, i + width))
		if (not printedPointer and action.sourceMap.start - i < width) then
			printedPointer = true
			print(
				string.rep(' ', action.sourceMap.start - i) .. '^' .. string.rep(' ', width - (action.sourceMap.start - i) + 1)
			)
		else
			print(blankLine)
		end
		i = i + width
	end

	local x, y = term.getCursorPos()
	term.setCursorPos(1, y - (lines * 2))
end

function Go:onBeforeRunAction(action)
	if (not self.silentMode) then
		self:printSourceMap(action)
	end

	if (self.pauseOnNext) then
		local wait = true
		while (wait) do
			local e, key = os.pullEvent('key')

			if (key == keys.enter) then
				wait = false
			elseif (key == keys.space) then
				wait = false
				self.pauseOnNext = false
			end
		end
	end
end

function Go:saveCommandToHistory(input)
	--TODO: save go commands to history
end

function Go:execute(input, silentMode)
	self:saveCommandToHistory(input)
	self.inp = input
	self.inputClean = input:gsub('%%', ' ')
	self.lim = #input

	if (type(silentMode) == 'boolean') then
		self.silentMode = silentMode
	end

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
		all = Sequence(all)
		all.sourceMap.start = 1
		all.sourceMap.ed = #self.inp
	else
		all = self.tokens[1]
	end

	all.owner = self

	all:run(ActionInvocation())

	if (not self.silentMode and #self.tokens > 1) then
		for i = 1, math.ceil(#self.inputClean / term.getSize()) do
			print()
			print()
		end
	end
end
