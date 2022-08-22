local result = {mov:locate()}
if (result[1]) then
	print(tostring(mov:getPosition()))
else
	print('Could not find location')
	print(result[3])
end
