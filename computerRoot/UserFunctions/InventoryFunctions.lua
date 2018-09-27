registerUserFunction(
	function(itemOrIndex, selector)
		if (tonumber(itemOrIndex) ~= nil) then
			print(InventoryManager.ItemIs(tonumber(itemOrIndex), selector))
		else
			print(InventoryManager.ItemIs(itemOrIndex, selector))
		end
	end,
	'itemIs',
	'itemOrIndex',
	'selector'
)
