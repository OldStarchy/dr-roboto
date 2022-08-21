includeOnce 'lib/Data/CompletionTree'

shell.setCompletionFunction(
	'tap.lua',
	function(shell, index, text, previousText)
		if (stringutil.startsWith(text, '-')) then
			local tree = CompletionTree()

			tree:addWord('--addRepository')
			tree:addWord('--removeRepository')
			tree:addWord('--listRepositories')
			tree:addWord('-p')
			tree:addWord('-f')
			tree:addWord('-b')
			tree:addWord('-s')
			tree:addWord('-h')
			tree:addWord('-q')

			return tree:getTruncatedCompletions(text)
		end

		-- adding '_' forces getDir to respect trailing slash in text
		local dir = fs.getDir(text .. '_')
		if (not fs.exists(dir)) then
			return nil
		end

		local listing = fs.list(dir)
		local tree = CompletionTree()

		for _, file in ipairs(listing) do
			local f = fs.combine(dir, file)
			if (fs.isDir(f)) then
				f = f .. '/'
			end
			tree:addWord(f)
		end

		return tree:getTruncatedCompletions(text)
	end
)
