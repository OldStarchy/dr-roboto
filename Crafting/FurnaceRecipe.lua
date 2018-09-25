FurnaceRecipe = Class(Recipe)
FurnaceRecipe.ClassName = 'FurnaceRecipe'

--[[
	name: name of the item that the recipe will produce.
	ingredient: name of an item or recipe that the furnace requires
	burnTime: a number representing how long it would take to furnace one of these.
	produces: the number of items the recipe will produce.
]]
function FurnaceRecipe:constructor(name, ingredient, produces, burnTime)
	if not type(name) == 'string' then
		error('Name must be of type string')
	end

	if not type(produces) == 'number' then
		error('Produces must be of type number')
	end

	if not type(burnTime) == 'number' then
		error('Burn Time must be of type number')
	end

	if not type(ingredient) == 'string' then
		error('Ingredient must be of type string')
	end

	self.burnTime = burnTime
	self.name = name
	self.ingredient = ingredient
	self.produces = produces
end
