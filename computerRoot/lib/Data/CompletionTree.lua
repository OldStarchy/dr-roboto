CompletionTree = Class()
CompletionTree.ClassName = 'CompletionTree'

function CompletionTree:constructor()
	self._root = {}
end

function CompletionTree:addWord(word)
	assertParameter(word, 'word', 'string')

	local c = self._root

	for i = 1, #word do
		local char = word:sub(i, i)
		if (c.subwords == nil) then
			c.subwords = {}
		end

		if (c.subwords[char] == nil) then
			c.subwords[char] = {}
		end

		c = c.subwords[char]
	end

	c.isWord = true
end

function CompletionTree:_reduce(tree)
	if (tree.subwords == nil or tree.isWord) then
		return tree
	end

	local result = {}
	for word, subtree in pairs(tree.subwords) do
		local subtree = self:_reduce(subtree)

		if (subtree.subwords and countKeys(subtree.subwords) == 1) then
			local subword, subsubtree = next(subtree.subwords)

			word = word .. subword
			subtree.isWord = subsubtree.isWord
			subtree.subwords = subsubtree.subwords
		end

		result[word] = subtree
	end

	return {
		isWord = tree.isWord,
		subwords = result
	}
end

function CompletionTree:_getCompletions(tree, prefix)
	if (tree.subwords == nil) then
		if (tree.isWord) then
			return {prefix}
		else
			return {}
		end
	end

	local completions = {}

	if (tree.isWord or (countKeys(tree.subwords) > 1 and prefix ~= '')) then
		table.insert(completions, prefix)
	end

	for char, subtree in pairs(tree.subwords) do
		concatTables(completions, self:_getCompletions(subtree, prefix .. char))
	end

	return completions
end

function CompletionTree:getCompletions()
	local reduced = self:_reduce(self._root)

	local completions = self:_getCompletions(reduced, '')

	table.sort(completions)

	return completions
end
