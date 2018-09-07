if (term == nil or not term.isColor()) then
	return setmetatable(
		{
			print = function(...)
				for k, v in ipairs(arg) do
					io.write(v)
				end
			end
		},
		{
			__index = function()
				return ''
			end
		}
	)
end

local exports = {}

for i, v in pairs(colors) do
	if (type(v) == 'number') then
		exports[i] = '&{' .. v .. '}'
	end
end

exports.print = function(...)
	local s = '&{' .. term.getTextColor() .. '}'
	for k, v in ipairs(arg) do
		s = s .. v
	end
	s = s .. '&{' .. term.getTextColor() .. '}'

	local fields = {}
	local lastcolor, lastpos = term.getTextColor(), 0
	for pos, clr, epos in s:gmatch '()&{(%x+)}()' do
		table.insert(fields, {s:sub(lastpos, pos - 1), lastcolor})
		lastcolor, lastpos = clr, epos
	end

	for i = 1, #fields do
		term.setTextColor(tonumber(fields[i][2]))
		io.write(fields[i][1])
	end
	term.setTextColor(tonumber(lastcolor))
end

return exports
