Log = Class()
Log.ClassName = 'Log'

Log.INFO = 0
Log.WARNING = 1
Log.ERROR = 2

Log.levels = {
	[0] = 'I',
	[1] = 'W',
	[2] = 'E'
}

--[[
	name - A label to appear next to ech log
	level - The minimum log level to log
	output - An output function like term.write that will not append newlines automatically
]]
function Log:constructor(name, level, output)
	self.name = name
	self.level = level or Log.INFO
	self.output = output or function(...)
			io.write(...)
		end
end

function Log:log(level, ...)
	if (self == nil) then
		self = Log.default
	end

	if (level >= self.level) then
		if (self.name) then
			self.output(self.name .. '|' .. Log.levels[level] .. '] ')
		end

		self.output(...)

		self.output('\n')
	end
end

function Log:info(...)
	if (self == nil) then
		self = Log.default
	end

	self:log(Log.INFO, unpack({...}))
end

function Log:warning(...)
	if (self == nil) then
		self = Log.default
	end

	self:log(Log.WARNING, unpack({...}))
end

function Log:error(...)
	if (self == nil) then
		self = Log.default
	end

	self:log(Log.ERROR, unpack({...}))
end

Log.default = Log('', Log.INFO)

function info(...)
	Log.default:info(...)
end

function warning(...)
	Log.default:warning(...)
end
