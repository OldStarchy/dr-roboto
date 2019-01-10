cprint = {}

for i, v in pairs(colors) do
	if (type(v) == 'number') then
		cprint[i] = '&{' .. v .. '}'
	end
end

if (term.isColor()) then
	setmetatable(
		cprint,
		{
			__call = function(_, ...)
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
		}
	)
else
	setmetatable(
		cprint,
		{
			__call = function(_, ...)
				local fields = {}
				local lastpos = term.getTextColor()
				local s = ''
				for k, v in ipairs(arg) do
					s = s .. v
				end
				for pos, _, epos in s:gmatch '()&{(%x+)}()' do
					table.insert(fields, {s:sub(lastpos, pos - 1)})
					lastpos = epos
				end

				for i = 1, #fields do
					io.write(fields[i][1])
				end
			end
		}
	)
end
