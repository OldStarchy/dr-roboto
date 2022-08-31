_G.term = {
	getSize = function()
		return 120, 400
	end,
	isColor = function()
		return false
	end,
	isColour = function()
		return false
	end,
	write = function(...)
		io.write(...)
	end,
	getTextColor = function()
		return colors.white
	end,
	getTextColour = function()
		return colours.white
	end,
	getBackgroundColor = function()
		return colors.black
	end,
	getBackgroundColour = function()
		return colours.black
	end,
	setTextColor = function(col)
	end,
	setTextColour = function(col)
	end,
	setBackgroundColor = function(col)
	end,
	setBackgroundColour = function(col)
	end,
	setCursorBlink = function(blink)
	end
}
