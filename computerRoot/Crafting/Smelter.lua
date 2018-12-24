Smelter = Class()
Smelter.ClassName = 'Smelter'

function Smelter:constructor(turtle)
	self._book = RecipeBook()

	self._turtle = turtle
end

function Smelter:setRecipeBook(recipeBook)
	if (recipeBook == nil) then
		self._book = RecipeBook()
	end

	if (recipeBook.getType() ~= RecipeBook) then
		error('Setting a non-book as the crafting recipe book')
	end

	self._book = recipeBook
end

function Smelter:setFurnace(furnace)
	-- set the furnace that the smelter will use. there may be many furnaces that are available within the map
	-- smelter will manage smelting arrays and collections of furnaces.
end

-- optional value of how many furnaces to setup.
function Smelter:setup(furnaces)
	numberOfFunaces = furnaces or 1
	-- create and place a furnace in a wise location.
end
