Matrix = Class()
Matrix.ClassName = 'Matrix'

--3x3 matrix for 2d transformations

function Matrix:constructor()
	self.m = {}
	self.m[1] = {}
	self.m[2] = {}
	self.m[3] = {}
	self.m[1][1] = 1
	self.m[1][2] = 0
	self.m[1][3] = 0
	self.m[2][1] = 0
	self.m[2][2] = 1
	self.m[2][3] = 0
	self.m[3][1] = 0
	self.m[3][2] = 0
	self.m[3][3] = 1
end

function Matrix:set(x, y, value)
	self.m[x][y] = value
end

function Matrix:get(x, y)
	return self.m[x][y]
end

function Matrix:copy(other)
	for x = 1, 3 do
		for y = 1, 3 do
			self.m[x][y] = other.m[x][y]
		end
	end
	return self
end

function Matrix:multiply(m)
	local result = Matrix()
	for x = 1, 3 do
		for y = 1, 3 do
			local sum = 0
			for i = 1, 3 do
				sum = sum + self:get(x, i) * m:get(i, y)
			end
			result:set(x, y, sum)
		end
	end
	return self:copy(result)
end

function Matrix:translate(x, y)
	local m = Matrix()
	m:set(1, 3, x)
	m:set(2, 3, y)
	return self:multiply(m)
end

function Matrix:scale(x, y)
	local m = Matrix()
	m:set(1, 1, x)
	m:set(2, 2, y)
	return self:multiply(m)
end

function Matrix:rotate(angle)
	local m = Matrix()
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	m:set(1, 1, cos)
	m:set(1, 2, -sin)
	m:set(2, 1, sin)
	m:set(2, 2, cos)
	return self:multiply(m)
end

function Matrix:invert()
	local m = Matrix()
	local det = self:determinant()
	if det == 0 then
		return m
	end
	m:set(1, 1, self:get(2, 2) / det)
	m:set(1, 2, -self:get(1, 2) / det)
	m:set(2, 1, -self:get(2, 1) / det)
	m:set(2, 2, self:get(1, 1) / det)
	return m
end

function Matrix:determinant()
	return self:get(1, 1) * self:get(2, 2) - self:get(1, 2) * self:get(2, 1)
end

function Matrix:clone()
	local m = Matrix()
	for x = 1, 3 do
		for y = 1, 3 do
			m:set(x, y, self:get(x, y))
		end
	end
	return m
end

local MatrixMeta = getmetatable(Matrix)
function MatrixMeta:__tostring()
	local str = ''
	for x = 1, 3 do
		for y = 1, 3 do
			str = str .. self:get(x, y) .. ' '
		end
		str = str .. '\n'
	end
	return str
end

function MatrixMeta:__eq(m)
	for x = 1, 3 do
		for y = 1, 3 do
			if self:get(x, y) ~= m:get(x, y) then
				return false
			end
		end
	end
	return true
end

function MatrixMeta:__add(m)
	local result = Matrix()
	for x = 1, 3 do
		for y = 1, 3 do
			result:set(x, y, self:get(x, y) + m:get(x, y))
		end
	end
	return result
end

function MatrixMeta:__sub(m)
	local result = Matrix()
	for x = 1, 3 do
		for y = 1, 3 do
			result:set(x, y, self:get(x, y) - m:get(x, y))
		end
	end
	return result
end

function MatrixMeta:__mul(m)
	local result = self:clone()
	return result:multiply(m)
end

function MatrixMeta:__div(m)
	local result = self:clone()
	return result:multiply(m:invert())
end

function MatrixMeta:__unm()
	local result = self:clone()
	return result:invert()
end

function Matrix:transformPoint(x, y)
	local _x = self:get(1, 1) * x + self:get(1, 2) * y + self:get(1, 3)
	local _y = self:get(2, 1) * x + self:get(2, 2) * y + self:get(2, 3)
	local _z = self:get(3, 1) * x + self:get(3, 2) * y + self:get(3, 3)

	return _x / _z, _y / _z
end
