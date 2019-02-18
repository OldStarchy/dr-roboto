FurnaceRecipe = Class(Recipe)
FurnaceRecipe.ClassName = 'FurnaceRecipe'

--[[
	name: name of the item that the recipe will produce.
	ingredient: name of an item or recipe that the furnace requires
	burnTime: a number of seconds it would take to furnace one of these.
	produces: the number of items the recipe will produce.
]]
function FurnaceRecipe:constructor(name, ingredient, produces, burnTime)
	assertType(name, 'string', 'Name must be of type string', 3)
	assertType(ingredient, 'string', 'Ingredient must be of type string', 3)
	assertType(produces, 'int', 'Produces must be of type number', 3)
	burnTime = assertType(coalesce(burnTime, 12), 'int', 'Burn Time must be of type number', 3)

	self.burnTime = burnTime
	self.name = name
	self.ingredient = ingredient
	self.produces = produces
end

function FurnaceRecipe:serialize()
	return {
		burnTime = self.burnTime,
		name = self.name,
		ingredient = self.ingredient,
		produces = self.produces
	}
end

function FurnaceRecipe.Deserialize(tbl)
	return FurnaceRecipe(tbl.name, tbl.ingredient, tbl.produces, tbl.burnTime)
end
