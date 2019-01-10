log = {}
local writers = {}

function log.log(typ, message, frameIndex)
	if (type(frameIndex) ~= 'number') then
		frameIndex = 2
	end

	local info = getStackFrameInfo(frameIndex + 1)

	for _, logWriter in ipairs(writers) do
		logWriter.log(typ, message, info)
	end
end

function log.info(message, frameIndex)
	if (type(frameIndex) == 'number') then
		frameIndex = frameIndex + 1
	else
		frameIndex = 2
	end

	log.log('info', message, frameIndex)
end

function log.warn(message, frameIndex)
	if (type(frameIndex) == 'number') then
		frameIndex = frameIndex + 1
	else
		frameIndex = 2
	end

	log.log('warn', message, frameIndex)
end

function log.error(message, frameIndex)
	if (type(frameIndex) == 'number') then
		frameIndex = frameIndex + 1
	else
		frameIndex = 2
	end

	log.log('error', message, frameIndex)
end

function log.addWriter(writer)
	writers[writer] = #writers + 1
	writers[#writers + 1] = writer
end

function log.removeWriter(writer)
	if (writers[writer] == nil) then
		return
	end

	table.remove(writers, writers[writer])
	writers[writer] = nil
end
