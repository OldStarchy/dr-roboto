local name = ({...})[1]

local f = fs.open(name, 'w')
local writer = {}

local widest = 3
function writer.log(typ, message, frameInfo)
	local proc = process.getCurrentProcess()
	if (proc) then
		local char = ':'
		if (proc.daemon) then
			char = '_'
		end

		local prefix = proc.name .. ' (' .. proc.id .. ')'
		if (#prefix > widest) then
			widest = #prefix
		end

		f.write(stringutil.lPad(prefix, widest) .. char .. ' ' .. message .. '\n')
	else
		f.write(stringutil.lPad('[0]', widest) .. ': ' .. message .. '\n')
	end
	f.flush()
end

return writer
