function math.minMax(a, b)
	if (a < b) then
		return a, b
	else
		return b, a
	end
end

function math.clamp(min, val, max)
	if (val < min) then
		return min
	elseif (val > max) then
		return max
	end
	return val
end
