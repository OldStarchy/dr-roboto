Cli = Class()
Cli.ClassName = 'Cli'

function Cli:constructor(name, description, default)
	self._name = assertType(coalesce(name, self:getType().ClassName), 'string')
	self._description = assertType(coalesce(description, ''), 'string')

	self._actions = {}

	if (type(default == 'string')) then
		default = {default}
	end
	self._default = assertType(coalesce(default, {'help'}), 'table')

	local this = self
	self:addAction(
		'help',
		function()
			this:printUsage()
		end,
		nil,
		'Shows this help text'
	)
end

function Cli:addAction(name, func, args, description)
	local action = {}
	action.name = assertType(name, 'string')
	if (#name == 0) then
		error('Name must be at least one character', 2)
	end

	action.func = assertType(func, 'function')
	if (type(args) == 'string') then
		args = {args}
	end
	action.args = assertType(coalesce(args, {}), 'table')
	action.description = assertType(coalesce(description, ''), 'string')

	self._actions[name] = action
end

function Cli:printUsage()
	print(self._name)
	if (self._description ~= '') then
		print(' ' .. self._description)
	end
	print()
	for name, action in pairs(self._actions) do
		local str = ' ' .. self._name .. ' ' .. name

		for _, v in ipairs(action.args) do
			str = str .. ' ' .. v
		end
		print(str)
		print('  ' .. action.description)
	end
end

function Cli:run(...)
	local args = {...}

	if (#args == 0) then
		args = self._default
	end

	local cmd = table.remove(args, 1)
	if (self._actions[cmd] ~= nil) then
		self._actions[cmd].func(unpack(args))
	else
		print('Invalid argument "' .. cmd .. '". Try "' .. self._name .. ' help" for usage.')
	end
end
