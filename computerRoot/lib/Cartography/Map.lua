Map = Class()
Map.ClassName = 'Map'
Map.version = '1';

function Map:constructor()
	self.ev = EventManager()

	self._points = {}
end

function Map:serialize()
	return {
		version = Map.version,
		points = self._points,
	}
end

function Map.Deserialize(tbl)
	local version = tbl.version

	if (version == '1') then
		local obj = Map()
		obj._points = tbl.points
		return obj
	else
		error('Unsupported map version: ' .. version)
	end
end

function Map:saveToVoxelsVox(filename)
	local file = fs.open(filename, 'w')

	if (file == nil) then
		error('Could not open file for writing: ' .. filename)
	end

	local layers = {}
	local layersByName = {}
	local palette = {}
	local colors = {}

	local function getLayer(name)
		if (layersByName[name] == nil) then
			local layer = {
				name = name,
				visible = true,
				locked = false,
				voxels = {},
			}
			layersByName[name] = layer
			table.insert(layers, layer)
		end

		return layersByName[name]
	end


	for x, yzs in pairs(self._points) do
		for y, zs in pairs(yzs) do
			for z, data in pairs(zs) do
				if (data.protected) then
					local layer = getLayer(data.layer or 'Protected')

					local color = data.color or 0x888888
					if (not colors[color]) then
						table.insert(palette, color)
						colors[color] = #palette
					end
					local colorIndex = colors[color]

					table.insert(
						layer.voxels,
						{x, y, z, colorIndex}
					)
				end
			end
		end
	end

	local json = {
		name = 'Voxels',
		settings = {
			linesColor = 0,
			showOutline = false,
			showWireframe = true,
			enableLighting = true,
			showBoundingBox = false,
		},
		layers = layers,
		palette = palette
	}

	file.write(textutils.serializeJSON(json))
	file.close()
	print('Saved map to ' .. filename)
end

function Map:saveToVoxelsTxt(filename)
	local file = fs.open(filename, 'w')

	if (file == nil) then
		error('Could not open file for writing: ' .. filename)
	end

	for x, yzs in pairs(self._points) do
		for y, zs in pairs(yzs) do
			for z, data in pairs(zs) do
				if (data.protected) then
					file.write(
						tostring(x) .. ', ' ..
						tostring(y) .. ', ' ..
						tostring(z) .. ', ' ..
						'128, 128, 128\n'
					)
				end
			end
		end
	end

	file.close()
	print('Saved map to ' .. filename)
end


function Map:saveToVoxelsJson(filename)
	local xmin, xmax = 0, 0
	local ymin, ymax = 0, 0
	local zmin, zmax = 0, 0

	local voxels = {}

	local function addVoxel(x, y, z)
		if (x < xmin) then
			xmin = x
		end
		if (x > xmax) then
			xmax = x
		end
		if (y < ymin) then
			ymin = y
		end
		if (y > ymax) then
			ymax = y
		end
		if (z < zmin) then
			zmin = z
		end
		if (z > zmax) then
			zmax = z
		end

		table.insert(voxels, {
			id = 'voxel_' .. tostring(#voxels),
			x = x,
			y = y,
			z = z,
			red = 128,
			green = 128,
			blue = 128,
		})
	end

	for x, yzs in pairs(self._points) do
		for y, zs in pairs(yzs) do
			for z, data in pairs(zs) do
				if (data.protected) then
					addVoxel(x, y, z)
				end
			end
		end
	end

	local width = xmax - xmin + 1
	local height = ymax - ymin + 1
	local depth = zmax - zmin + 1

	local json = {
		dimension = {
			width = width,
			height = height,
			depth = depth,
		},
		voxels = voxels,
	}

	local file = fs.open(filename, 'w')
	file.write(textutils.serializeJSON(json))
	file.close()
	print('Saved map to ' .. filename)
end


function Map:_getData(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if (self._points[x] == nil) then
		return nil
	end

	if (self._points[x][y] == nil) then
		return nil
	end

	return self._points[x][y][z]
end

function Map:_getOrCreateData(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if (self._points[x] == nil) then
		self._points[x] = {}
	end

	if (self._points[x][y] == nil) then
		self._points[x][y] = {}
	end

	if (self._points[x][y][z] == nil) then
		self._points[x][y][z] = {}
	end

	return self._points[x][y][z]
end

local function rgbToColor(r, g, b)
	return r * 65536 + g * 256 + b
end

function Map:setProtected(pos, protected, layer, r, g, b)
	assertType(pos, Position)

	local data = self:_getOrCreateData(pos)
	data.protected = protected
	data.layer = layer
	if (r) then
		data.color = rgbToColor(r, g, b)
	end

	self.ev:trigger('protected', pos, protected)
	self.ev:trigger('state_changed')
end

function Map:isProtected(pos)
	assertType(pos, Position)

	local data = self:_getData(pos)

	if (data == nil) then
		return false
	end

	return data.protected
end

function Map:getData(pos)
	assertType(pos, Position)

	return self:_getData(pos)
end
