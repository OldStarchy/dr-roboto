Log = Class()

Log.INFO = 0
Log.WARNING = 1
Log.ERROR = 2

function Log:constructor(name, level, output)
	self.name = name
	self.level = level or Log.INFO
	self.output = output or print
end

function Log:log(level, ...)
	if (self == nil) then
		self = Log.default
	end

	if (level >= self.level) then
		if (self.name) then
			self.output(self.name .. '] ')
		end

		self.output(...)
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

Log.default = Log.new('', Log.INFO)
