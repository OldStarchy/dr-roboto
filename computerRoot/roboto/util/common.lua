function coalesce(...)
	local args = {...}
	for i, v in pairs(args) do
		if (v ~= nil) then
			return v
		end
	end
	return nil
end

--[[
	Asks the user for input.
	Loops forever until an acceptable answer is given.

	if options is nil, any answer is returned
	if options is a table, the question will loop until an answer in options is given
	if default is not nil, an empty response will use the default value
]]
function ask(question, options, default)
	while (true) do
		print(question)
		local answer = read()

		if (answer == '' and default ~= nil) then
			answer = default
		end

		if (options == nil) then
			return answer
		end
		for _, v in ipairs(options) do
			if (answer == v) then
				return answer
			end
		end
	end
end
