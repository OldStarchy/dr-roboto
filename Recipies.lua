local recipies = {}

local Recipie = Class()

function Recipie.constructor(self, name,, grid, produces)
	self.name = name
	self.grid = grid
	self.produces = produces
	
	-- self.items = items

	recipies[name] = self
end

Recipie.new('plank', {'log'}, 4)
Recipie.new('stick', {'plank', nil, nil, 'plank'}, 4)
Recipie.new('torch', {'coal', nil, nil, 'stick'}, 4)
