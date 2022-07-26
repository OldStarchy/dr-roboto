Logger = Class()
Logger.ClassName = 'Logger'

function Logger:constructor()
	self._writers = {}
end

function Logger:createAPI()
	return setmetatable(
		{},
		{
			__index = function(t, k)
				local v = self[k]
				if (type(v) == 'function') then
					return function(...)
						return v(self, ...)
					end
				end
				return v
			end
		}
	)
end

function Logger:log(typ, message, frameIndex)
	if (type(frameIndex) ~= 'number') then
		frameIndex = 2
	end

	local info = debug.getinfo(frameIndex + 1)

	for _, logWriter in ipairs(self._writers) do
		logWriter:log(typ, message, info)
	end
end

function Logger:info(message, frameIndex)
	if (type(frameIndex) == 'number') then
		frameIndex = frameIndex + 1
	else
		frameIndex = 2
	end

	self:log('info', message, frameIndex)
end

function Logger:warn(message, frameIndex)
	if (type(frameIndex) == 'number') then
		frameIndex = frameIndex + 1
	else
		frameIndex = 2
	end

	self:log('warn', message, frameIndex)
end

function Logger:error(message, frameIndex)
	if (type(frameIndex) == 'number') then
		frameIndex = frameIndex + 1
	else
		frameIndex = 2
	end

	self:log('error', message, frameIndex)
end

function Logger:addWriter(writer)
	self._writers[writer] = #self._writers + 1
	self._writers[#self._writers + 1] = writer
end

function Logger:removeWriter(writer)
	if (type(writer) == 'number') then
		if (writer <= #self._writers) then
			if (writer > 0) then
				self._writers[self._writers[writer]] = nil
				table.remove(self._writers, writer)
				return
			end
		end
		error('invalid writer id to remove', 2)
	end
	if (self._writers[writer] == nil) then
		return
	end

	table.remove(self._writers, self._writers[writer])
	self._writers[writer] = nil
end
