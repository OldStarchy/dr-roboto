function obtain(item, amount)
	if (amount < 0) then
		error('Call to obtain with negative amount')
	end

	local existing = 0

	existing = existing + Inventory.itemCount(item)
	existing = existing + ItemStorage.itemCount(item)

	if (existing > amount) then
		return true
	end

	return Crafting.craft(item, amount - existing)
end
