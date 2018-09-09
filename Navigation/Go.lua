local ActionResult = Class()
function ActionResult:constructor(action, success, data)
	self.action = action
	if (type(success) == 'boolean') then
		self.success = success
	else
		self.success = true
	end
	self.data = data
end

local ActionInvocation = Class()
function ActionInvocation:constructor(optional, previousResult)
	self.optional = optional
	self.previousResult = previousResult or ActionResult.new()
end

local Action = Class()

Action.RETRY = 'retry'
Action.IGNORE = 'ignore'
Action.ABORT = 'abort'

function Action.getFactory(func)
	return function()
		return Action.new(
			function(optional)
				local success, m = func()
				if not success and not optional then
					while not success do
						success, m = func()
						sleep(0)
					end
					return success, m
				end
				return success, m
			end
		)
	end
end

function Action:constructor(func)
	-- The function that this action object represents executing
	self.func = func

	self.times = 1
	self.optional = false
	self.type = 'abstract action'
	self.invert = false
	self.arguments = nil
	self.count = 1
end

function Action:innerFunction()
end

function Action:singleInvoke()
	return self.innerFunction(table.unpack(self.arguments)) or true
end

function Action:invoke(invoc)
end

function Action:call(invoc)
	return ActionResult.new(self, self.func(invoc.optional))
end

function Action:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local i = 1
	local r

	while self.count == -1 or i <= self.count do
		r = self:call(ActionInvocation.new(optional, invoc.previousResult))
		success = r.success ~= self.invert

		if not success then
			if self.optional then
				return ActionResult.new(self, true, r.data)
			elseif optional then
				return ActionResult.new(self, false, r.data)
			else
				i = i - 1
			end
		end

		i = i + 1
	end

	return ActionResult.new(self, true ~= self.invert, r.data)
end

function Action:mod(mod)
	if type(mod) == 'number' then
		self.count = mod
		return true
	end

	if type(mod) == 'string' then
		if mod == '?' then
			self.optional = true
			return true
		end

		if mod == '*' then
			self.count = -1
			return true
		end

		if mod == '~' then
			self.invert = true
			return true
		end
	end

	return false
end

local MoveAction = Class(Action)
function MoveAction.getFactory(func)
	return function()
		return MoveAction.new(
			function(optional)
				local success, m = func()
				if not success and not optional then
					while not success do
						success, m = func()
						sleep(0)
					end
				end
				return success, m
			end
		)
	end
end
function MoveAction:constructor(func)
	Action.constructor(self, func)
	self.autoDigAtack = false
end

function MoveAction:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local i = 1
	local r

	while self.count == -1 or i <= self.count do
		local autoDig = Nav.autoDig
		local autoAttack = Nav.autoAttack

		if (optional) then
			Nav.autoDig = false
		end
		if (self.autoDigAttack) then
			Nav.autoDig = true
			Nav.autoAttack = true
		end
		r = self:call(ActionInvocation.new(optional, invoc.previousResult))
		Nav.autoDig = autoDig
		Nav.autoAttack = autoAttack

		success = r.success ~= self.invert

		if not success then
			if self.optional then
				return ActionResult.new(self, true, r.data)
			elseif optional then
				return ActionResult.new(self, false, r.data)
			else
				i = i - 1
			end
		end

		i = i + 1
	end

	return ActionResult.new(self, true ~= self.invert, r.data)
end
function MoveAction:mod(mod)
	if (Action.mod(self, mod)) then
		return true
	end

	if type(mod) == 'string' then
		if mod == '!' then
			self.autoDigAttack = true
			return true
		end
	end

	return false
end

local Sequence = Class(Action)
function Sequence.getFactory(actions)
	return function()
		return Sequence.new(actions)
	end
end
function Sequence:constructor(actions)
	self.count = 1
	self.optional = false
	self.retry = false
	self.seq = actions
end

function Sequence:run(invoc)
	local optional = invoc.optional or self.optional
	local success
	local r = nil
	local i = 1

	while self.count == -1 or i <= self.count do
		r = invoc.previousResult

		for _, v in ipairs(self.seq) do
			r = v:run(ActionInvocation.new(self.retry or self.optional, r))
			success = r.success

			if not success then
				if self.retry then
					i = i - 1
					break
				elseif self.optional then
					return ActionResult.new(self, true ~= self.invert, r)
				elseif optional then
					return ActionResult.new(self, false ~= self.invert, r)
				else
					return ActionResult.new(self, false ~= self.invert, r)
				end
			end

			sleep(0)
		end

		i = i + 1
		sleep(0)
	end

	return ActionResult.new(self, true ~= self.invert, r)
end

function Sequence:mod(mod)
	if type(mod) == 'string' then
		if mod == '?' then
			if self.retry then
				inputError("Sequence can't be optional and retrying")
			end
			self.optional = true
			return true
		end

		if mod == '!' then
			if self.optional then
				inputError("Sequence can't be optional and retrying")
			end
			self.retry = true
			return true
		end
	end

	return Action.mod(self, mod)
end

local Go = Class()
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

--[[ Actions ]]
local FindAction = Class(Action)
function FindAction.getFactory(func)
	return function()
		return FindAction.new(func)
	end
end
function FindAction:constructor(findFunc)
	self.findFunc = findFunc
	self.findstr = nil
	self.metadata = nil
end

function FindAction:call(invoc)
	local success, result
	success, result = self.findFunc()

	if not success then
		return ActionResult.new(self, false)
	end

	if not self.findstr then
		return ActionResult.new(self, true, result.name)
	end

	if not string.find(result.name, self.findstr, 1, true) then
		return ActionResult.new(self, false, result.name)
	end

	if not self.metadata then
		return ActionResult.new(self, true, result.name)
	end

	if result.metadata == self.metadata then
		return ActionResult.new(self, true)
	end

	return ActionResult.new(self, false, result.metadata)
end
function FindAction:mod(mod)
	if type(mod) == 'number' then
		self.metadata = mod
		return true
	end

	if type(mod) == 'table' then
		self.findstr = mod.str
		return true
	end

	return Action.mod(self, mod)
end

local ItemAction = Class(Action)
function ItemAction.getFactory(func)
	return function()
		return ItemAction.new(func)
	end
end
function FindAction:constructor(itemFunc)
	self.itemFunc = itemFunc
	self.amount = nil
end

function FindAction:call(invoc)
	local success
	if self.amount ~= nil then
		success = self.itemFunc(self.amount)
	else
		success = self.itemFunc()
	end

	return ActionResult.new(self, success)
end
function FindAction:mod(mod)
	if type(mod) == 'number' then
		self.amount = mod
		return true
	end

	return Action.__index.mod(self, mod)
end

local AttachmentAction = Class(Action)
function AttachmentAction.getFactory(func)
	return function()
		return AttachmentAction.new(func)
	end
end
function AttachmentAction:constructor(itemFunc)
	self.itemFunc = itemFunc
end
function AttachmentAction:call(self, invoc)
	return ActionResult.new(self, self.itemFunc())
end

local go = Go.new()

go:alias({'f', 'forward', 'forwards'}, MoveAction.getFactory(turtle.forward))
go:alias({'b', 'back', 'backward', 'backwards'}, MoveAction.getFactory(turtle.back))
go:alias({'l', 'left'}, Action.getFactory(turtle.turnLeft))
go:alias({'r', 'right'}, Action.getFactory(turtle.turnRight))
go:alias({'u', 'up'}, MoveAction.getFactory(turtle.up))
go:alias({'d', 'down'}, MoveAction.getFactory(turtle.down))

go:alias({'D', 'dig'}, AttachmentAction.getFactory(turtle.dig))
go:alias({'D^', 'digUp'}, AttachmentAction.getFactory(turtle.digUp))
go:alias({'Dv', 'digDown'}, AttachmentAction.getFactory(turtle.digDown))

go:alias({'P', 'place'}, Action.getFactory(turtle.place))
go:alias({'P^', 'placeUp'}, Action.getFactory(turtle.placeUp))
go:alias({'Pv', 'placeDown'}, Action.getFactory(turtle.placeDown))

go:alias({'s', 'suck'}, ItemAction.getFactory(turtle.suck))
go:alias({'s^', 'suckUp'}, ItemAction.getFactory(turtle.suckUp))
go:alias({'sv', 'suckDown'}, ItemAction.getFactory(turtle.suckDown))

go:alias({'S', 'drop'}, ItemAction.getFactory(turtle.drop))
go:alias({'S^', 'dropUp'}, ItemAction.getFactory(turtle.dropUp))
go:alias({'Sv', 'dropDown'}, ItemAction.getFactory(turtle.dropDown))

go:alias(
	{'m'},
	function()
		return {
			mode = false,
			run = function(self, invoc)
				if (self.mode == 'angry') then
					Nav.autoDig = true
					Nav.autoAttack = true
				elseif (self.mode == 'nice') then
					Nav.autoDig = false
					Nav.autoAttack = false
				else
					print("m requires modifiers, either '?' to disable autodig, or '!' to enable it")
				end
				return ActionResult.new(self, true)
			end,
			mod = function(self, mod)
				if type(mod) == 'string' then
					if mod == '!' then
						self.mode = 'angry'
						return true
					end
					if mod == '?' then
						self.mode = 'nice'
						return true
					end
				end

				return false
			end
		}
	end
)

go:alias(
	{'L'},
	function()
		return {
			str = nil,
			run = function(self, invoc)
				local str =
					self.str or (type(invoc.previousResult.data) == 'string' and invoc.previousResult.data) or
					invoc.previousResult.success
				if not str then
					return ActionResult.new(self, false)
				end

				print(str)

				return ActionResult.new(self, true, str)
			end,
			mod = function(self, mod)
				if type(mod) == 'table' then
					if mod.str then
						self.str = mod.str
						return true
					end
				end

				return false
			end
		}
	end
)

go:alias(
	{'w', 'wait'},
	function()
		return {
			time = 1,
			run = function(self, invoc)
				sleep(self.time)
				return ActionResult.new(self, true, self.time)
			end,
			mod = function(self, m)
				if type(m) == 'number' then
					self.time = m
					return true
				end

				return false
			end
		}
	end
)

go:alias(
	{'#', 'select'},
	function()
		return {
			run = function(self, invoc)
				local s = self.index

				if self.incremental then
					s = turtle.getSelectedSlot() + s
				end

				if self.decremental then
					s = turtle.getSelectedSlot() - s
				end

				s = (s - 1) % 16 + 1

				turtle.select(s)
				return ActionResult.new(self, true, s)
			end,
			index = 1,
			incremental = false,
			decremental = false,
			mod = function(self, m)
				if type(m) == 'number' then
					self.index = m
					return true
				end

				if type(m) == 'string' then
					if m == '+' then
						if self.decremental then
							inputError("Can't go up and down at the same time")
						end
						self.incremental = true
						return true
					end

					if m == '-' then
						if self.incremental then
							inputError("Can't go up and down at the same time")
						end
						self.decremental = true
						return true
					end
				end

				return false
			end
		}
	end
)
go:alias({'F', 'find'}, FindAction.getFactory(turtle.inspect))
go:alias({'F^', 'findUp'}, FindAction.getFactory(turtle.inspectUp))
go:alias({'Fv', 'findDown'}, FindAction.getFactory(turtle.inspectDown))
go:alias({'a', 'attack'}, AttachmentAction.getFactory(turtle.attack))
go:alias({'a^', 'attackUp'}, AttachmentAction.getFactory(turtle.attackUp))
go:alias({'av', 'attackDown'}, AttachmentAction.getFactory(turtle.attackDown))
go:alias(
	{'help'},
	function()
		return {
			run = function(self)
				local helpText =
					[[g is for go

  For stringing together all kinds of actions easily, even if somewhat confusingly.

  Use keywords
  ]]
				for i, v in pairs(go.factionKeys) do
					helpText = helpText .. '  ' .. table.concat(v, ', ') .. '\n'
				end
				helpText =
					helpText ..
					[[
      
  and modifiers,
    ?   to continue on failure
    X   to repeat X times
    *   to repeat infinitley

  group actions with ( and ) and use
    L   to log text


  Examples:
    Dig all the way down
      g (Dvd)*
      g (digDown down)*
    Build bridge / tunnel
      g (D^Dpv?)*
      g (digUp dig placeDown?)*
    Attack while spinning
      g (ar)*
      g (attack right)*
    The Pain dance:
      g L"Dancing"((fabrfabl)2L"ohh"u(ra)4dL"rocking it!"r4)*
      g L"Dancing"((forward attack back right forward attack back left)2 L"ooh" up (right attack)4 down L"rocking it!" right4)*
    Dig a 3x3 tunnel
      g (((Df)! Pv? l(D?f)!Pv?b (D^?u)! D? (D^?u)! D?r2 D? d D? d (Df)!Pv?b l)7 ((Df)! Pv?l(D?f)!Pv?b (D^?u)! D? #16P?#1 (D^?u)! D?r2 D? d D? d (Df)!Pv?b l))?*

  Speak to OldStarchy for bug reports and feature requests]]
				textutils.pagedPrint(helpText)
				return ActionResult.new(self, true)
			end
		}
	end
)

return go
