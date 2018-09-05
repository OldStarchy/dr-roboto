local Recipie = Class()

function Recipie.constructor(self, name, grid, produces)
	self.name = name
	self.grid = grid
	self.produces = produces

	-- self.items = items

	recipies[name] = self
end
