Crafting = {}

Crafting.buildCraftGraph = function(item, amount)
	local recipie = Recipes[item]
end

Crafting.craft = function(item, amount)
	local graph = Crafting.buildCraftGraph(item, amount)

	Crafting.craftFromGraph(graph)
end

Crafting.craftFromGraph = function(graph)
	local leafNodes = Graph.leafNodes(graph)

	local items = leafNodes.groupBy(item) --psudocode
	--foreach leaf node in items
	obtain(node.item, node.amount)
end

if (Debug ~= nil) then
	print('Debug')
end
