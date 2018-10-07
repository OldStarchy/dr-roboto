Interface = {}

setmetatable(
	Interface,
	{
		__call = function(_, ...)
			local interface = {}
			local interfaceMeta = {}
			local parents = {...}

			interfaceMeta.__call = function()
				error("Can't instantiate interface types", 2)
			end

			interfaceMeta.__index = {
				test = function(obj)
					if (#parents ~= 0) then
						for _, parent in pairs(parents) do
							if (not parent.test(obj)) then
								return false
							end
						end
					end

					for i, v in pairs(interface) do
						if (type(obj[i]) ~= v) then
							return false
						end
					end

					return true
				end,
				assertImplementation = function(obj, err, frame)
					frame = coalesce(frame, 1) + 1
					if (#parents ~= 0) then
						for _, parent in pairs(parents) do
							parent.assertImplementation(obj, frame + 1)
						end
					end

					for i, v in pairs(interface) do
						assert(type(obj[i]) == v, 'obj[' .. tostring(i) .. '] is ' .. type(obj[i]) .. ' not ' .. v, frame)
					end

					return obj
				end,
				isOrInherits = function(iface)
					if (interface == iface) then
						return true
					end

					if (#parents == 0) then
						return false
					end

					for i, v in pairs(parents) do
						if (v.isOrInherits(iface)) then
							return true
						end
					end

					return false
				end,
				isInterface = true
			}

			setmetatable(interface, interfaceMeta)

			return interface
		end
	}
)

function Interface.FromObject(obj)
	local interface = Interface()

	for i, v in pairs(obj) do
		interface[i] = type(v)
	end

	return interface
end
