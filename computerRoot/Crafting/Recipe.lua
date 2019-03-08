Recipe = Class()
Recipe.ClassName = 'Recipe'

function Recipe:constructor(output, outputCount)
	assertParameter(output, 'output', 'string')
	assertParameter(outputCount, 'outputCount', 'int')

	self.output = ItemDetail.NormalizeId(output)
	self.outputCount = outputCount
end

function Recipe:serialize()
	return {
		output = self.output,
		outputCount = self.outputCount
	}
end

includeAll 'Crafting/Recipe'
