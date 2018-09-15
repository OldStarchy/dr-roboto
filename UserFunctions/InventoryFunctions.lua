registerUserFunction(
	function(itemOrIndex, selector)
		if (tonumber(itemOrIndex) ~= nil) then
			print(Inventory.ItemIs(tonumber(itemOrIndex), selector))
		else
			print(Inventory.ItemIs(itemOrIndex, selector))
		end
	end,
	'itemIs',
	'itemOrIndex',
	'selector'
)
