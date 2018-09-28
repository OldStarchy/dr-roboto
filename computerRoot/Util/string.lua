function string:startsWith(start)
	return self:sub(1, #start) == start
end

function string:endsWith(ending)
	return ending == '' or self:sub(-(#ending)) == ending
end
