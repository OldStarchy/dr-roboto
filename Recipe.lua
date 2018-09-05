local recipes = {}

local Recipie = Class()

function Recipie.constructor(self, name, grid, produces)
	self.name = name
	self.grid = grid
	self.produces = produces

	-- self.items = items

	recipes[name] = self
end

function Recipie.find(name)
	return recipes[name]
end

require 'Recipes'

return Recipie
