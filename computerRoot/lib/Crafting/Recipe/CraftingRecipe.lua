includeOnce '../Recipe'

CraftingRecipe = Class(Recipe)
CraftingRecipe.ClassName = 'CraftingRecipe'

--[[
	name: name of the item that the recipe will produce.
	grid: a list of recipes or ingredients in string form, the list forms a 3x3 grid, to be interpreted as:
	  1,2,3
	  4,5,6
	  7,8,9
	produces: the number of items the recipe will produce.
]]
-- TODO: reorder to (name, produces, grid)
function CraftingRecipe:constructor(output, grid, outputCount)
	Recipe.constructor(self, output, outputCount)

	self.grid = cloneTable(assertParameter(grid, 'grid', 'table'))

	--the number of items required in the recipe
	self.itemCount = 0

	--a table of names of (ingredients or recepies) and their number quantity required
	self.items = {}
	for _, item in pairs(grid) do
		self.itemCount = self.itemCount + 1

		if (self.items[item] == nil) then
			self.items[item] = 1
		else
			self.items[item] = self.items[item] + 1
		end
	end
end

function CraftingRecipe:serialize()
	local tbl = Recipe.serialize(self)

	tbl.grid = cloneTable(self.grid)

	return tbl
end

function CraftingRecipe.Deserialize(tbl)
	return CraftingRecipe(tbl.output, tbl.grid, tbl.outputCount)
end
