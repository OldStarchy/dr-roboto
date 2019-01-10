local name = ({...})[1]

local f = fs.open(name, 'w')
local writer = {}

function writer.log(typ, message, frameInfo)
	f.write(message .. '\n')
	f.flush()
end

return writer
