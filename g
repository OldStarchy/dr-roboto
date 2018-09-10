go = include 'Go/_main'
local fArgs = {...}

-- seperatorCharacter is used as a marker to show where arguments were separated, this allows spaces in single quote strings, but only one space.
local input = table.concat(fArgs, go.speratorCharacter) .. go.speratorCharacter

if (#fArgs == 0) then
	input = 'help'
end

go:execute(input)
