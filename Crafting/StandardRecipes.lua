local book = RecipeBook.new()

book:add(Recipe.new('plank', {'log'}, 4))
book:add(Recipe.new('stick', {'plank', nil, nil, 'plank'}, 4))
book:add(Recipe.new('torch', {'coal', nil, nil, 'stick'}, 4))

return book
