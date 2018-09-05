local recipies = {}

local Recipe = require 'Recipe'

Recipe.new('plank', {'log'}, 4)
Recipe.new('stick', {'plank', nil, nil, 'plank'}, 4)
Recipe.new('torch', {'coal', nil, nil, 'stick'}, 4)
