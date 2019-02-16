dofile '../_polyfills/fs.lua'
dofile '../_polyfills/turtle.lua'
dofile '../_polyfills/os.lua'
dofile '../_polyfills/textutils.lua'
dofile '../_polyfills/bit.lua'
dofile '../_polyfills/term.lua'
dofile '../_polyfills/colours.lua'
dofile '../_polyfills/lua.lua'
sleep = function(count)
	count = tonumber(count)
	if (count == nil) then
		error('expected number of seconds', 2)
	end

	local t = os.time() + count

	repeat
	until os.time() > t
end
read = function()
	return io.read()
end
