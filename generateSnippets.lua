require 'lfs'
lfs.chdir('computerRoot')
dofile 'startup'
lfs.chdir('..')
-- Generates a snippets file for all the apis currently available on the computercraft computer its run on
-- The snippets file can be used in vscode to provide autocomplete.
-- Won't create snippets for things starting wtih an underscore, or for the 'turtle' namespace (because there's already a better set of turtle snippets in .vscode/luasnippets.json)
local done = {
	[debug] = true,
	[lfs] = true
}
local results = {}

local function iterateTable(tbl, prefix, depth)
	if (depth == nil) then
		depth = 1
	end
	if (done[tbl]) then
		return
	end
	done[tbl] = true

	local isClass = false
	if (tbl ~= _G and tbl.ClassName ~= nil) then
		isClass = true
		table.insert(results, prefix)
	end

	for i, v in pairs(tbl) do
		if (type(i) ~= 'string' or i:sub(1, 1) ~= '_') then
			if (type(v) == 'function') then
				if (prefix) then
					if (prefix ~= 'turtle') then
						if (isClass and i:sub(1, 1):lower() == i:sub(1, 1)) then
							if (i ~= 'constructor') then
								table.insert(results, prefix .. ':' .. i)
							end
						else
							table.insert(results, prefix .. '.' .. i)
						end
					end
				else
					table.insert(results, i)
				end
			elseif (type(v) == 'table' and depth > 0) then
				if (prefix) then
					iterateTable(v, prefix .. '.' .. i, depth - 1)
				else
					iterateTable(v, i, depth - 1)
				end
			end
		end
	end
end

local function iterateMetatables(tbl)
	iterateTable(tbl)

	pcall(
		function()
			while (tbl) do
				tbl = getmetatable(tbl).__index
				iterateTable(tbl)
			end
		end
	)
end

iterateMetatables(_G)

local ind = 1
f = fs.open('.vscode/luagenerated.code-snippets', 'w')
function writeSnippet(snippet)
end
f.write('{\n')

table.sort(results)

for i = 1, #results do
	local snippet = results[i]
	local text = ''
	text = text .. '\t"' .. snippet .. '()": {\n'
	text = text .. '\t\t"prefix": "' .. snippet .. '",\n'
	text = text .. '\t\t"body": [\n'
	text = text .. '\t\t\t"' .. snippet .. '($0)"\n'
	text = text .. '\t\t],\n'
	text = text .. '\t\t"description": ""\n'
	if (i == #results) then
		text = text .. '\t}\n'
	else
		text = text .. '\t},\n'
	end
	if
		(not pcall(
			function()
				f.write(text)
			end
		))
	 then
		f.close()
		f = fs.open('snippets' .. ind .. '.json', 'w')
		ind = ind + 1
		f.write(text)
	end
end
f.write('}')
f.close()
