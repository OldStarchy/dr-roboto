FurnaceRecipe = Class(Recipe)
FurnaceRecipe.ClassName = 'FurnaceRecipe'

--[[
	name: name of the item that the recipe will produce.
	ingredient: name of an item or recipe that the furnace requires
	burnTime: a number of seconds it would take to furnace one of these.
	produces: the number of items the recipe will produce.
]]
function FurnaceRecipe:constructor(output, ingredient, outputCount, burnTime)
	Recipe.constructor(self, output, outputCount)

	self.ingredient = ItemDetail.NormalizeId(assertParameter(ingredient, 'ingredient', 'string'))
	self.burnTime = assertParameter(coalesce(burnTime, 12), 'burnTime', 'int')
end

function FurnaceRecipe:serialize()
	local tbl = Recipe.serialize(self)
	tbl.ingredient = self.ingredient
	tbl.burnTime = self.burnTime
	return tbl
end

function FurnaceRecipe.Deserialize(tbl)
	return FurnaceRecipe(tbl.output, tbl.ingredient, tbl.outputCount, tbl.burnTime)
end
