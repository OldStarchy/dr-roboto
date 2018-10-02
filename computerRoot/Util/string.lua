function string:startsWith(start)
	return start == '' or self:sub(1, #start) == start
end

function string:endsWith(ending)
	return ending == '' or self:sub(-(#ending)) == ending
end

function string:isLower()
	return self:lower() == self
end

function string:isUpper()
	return self:upper() == self
end
