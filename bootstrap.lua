if (_G.fs == nil) then
	dofile '_polyfills/fs.lua'
	if (_G.turtle == nil) then
		dofile '_polyfills/turtle.lua'
	end
end

if (os.loadAPI == nil) then
	dofile '_polyfills/os.lua'
end

if (_G.require == nil) then
	dofile '_polyfills/require.lua'
end

if (fs.listRecursive == nil) then
	function fs.listRecursive(directory)
		local results = {}

		local dirsToCheck = {directory}

		while (#dirsToCheck > 0) do
			local currentDirectory = table.remove(dirsToCheck)
			local files = fs.list(currentDirectory)

			for _, file in ipairs(files) do
				if (fs.isDir(file)) then
					if (file ~= '.' and file ~= '..') then
						table.insert(dirsToCheck, currentDirectory .. '/' .. file)
					end
				else
					table.insert(results, currentDirectory .. '/' .. file)
				end
			end
		end

		return results
	end

	function dofileSandbox(filename, env)
		local status, result = assert(pcall(setfenv(assert(loadfile(filename)), env)))
		return result
	end

	function starts_with(str, start)
		return str:sub(1, #start) == start
	end

	function ends_with(str, ending)
		return ending == '' or str:sub(-(#ending)) == ending
	end
end

--[[
turtle.attackUp()

turtle.craft(number: quantity)

(returns:.*)\n(turtle\..*)\n(.*)
"$2": {\n"prefix": "$2",\n"body": [\n\t"$2"\n],\n"description": "$3. $1"\n},\n\n


]]
