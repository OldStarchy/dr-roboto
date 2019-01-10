function coalesce(...)
	local args = {...}
	for i, v in pairs(args) do
		if (v ~= nil) then
			return v
		end
	end
	return nil
end
