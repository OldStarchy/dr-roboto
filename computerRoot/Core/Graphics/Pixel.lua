Pixel = {
	NONE = 0,
	ALL = 63,
	TOP_LEFT = 1,
	TOP_RIGHT = 2,
	TOP = 3,
	MIDDLE_LEFT = 4,
	MIDDLE_RIGHT = 8,
	MIDDLE = 12,
	BOTTOM_LEFT = 16,
	BOTTOM_RIGHT = 32,
	BOTTOM = 48,
	LEFT = 21,
	RIGHT = 42,
	compile = function(...)
		local args = {...}
		local pixels = 0

		for _, v in ipairs(args) do
			pixels = bit.bor(pixels, v)
		end

		local invert = pixels >= 32
		if (invert) then
			pixels = bit.bxor(pixels - 32, 31)
		end

		return {
			char = string.char(bit.bor(128, pixels)),
			inverted = invert
		}
	end
}
