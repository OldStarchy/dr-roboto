local g_tLuaKeywords = {
	['and'] = true,
	['break'] = true,
	['do'] = true,
	['else'] = true,
	['elseif'] = true,
	['end'] = true,
	['false'] = true,
	['for'] = true,
	['function'] = true,
	['if'] = true,
	['in'] = true,
	['local'] = true,
	['nil'] = true,
	['not'] = true,
	['or'] = true,
	['repeat'] = true,
	['return'] = true,
	['then'] = true,
	['true'] = true,
	['until'] = true,
	['while'] = true
}

local function serializeImpl(t, tTracking, sIndent)
	local sType = type(t)
	if sType == 'table' then
		if tTracking[t] ~= nil then
			error('Cannot serialize table with recursive entries', 0)
		end
		tTracking[t] = true

		if next(t) == nil then
			-- Empty tables are simple
			return '{}'
		else
			-- Other tables take more work
			local sResult = '{\n'
			local sSubIndent = sIndent .. '  '
			local tSeen = {}
			for k, v in ipairs(t) do
				tSeen[k] = true
				sResult = sResult .. sSubIndent .. serializeImpl(v, tTracking, sSubIndent) .. ',\n'
			end
			for k, v in pairs(t) do
				if not tSeen[k] then
					local sEntry
					if type(k) == 'string' and not g_tLuaKeywords[k] and string.match(k, '^[%a_][%a%d_]*$') then
						sEntry = k .. ' = ' .. serializeImpl(v, tTracking, sSubIndent) .. ',\n'
					else
						sEntry =
							'[ ' .. serializeImpl(k, tTracking, sSubIndent) .. ' ] = ' .. serializeImpl(v, tTracking, sSubIndent) .. ',\n'
					end
					sResult = sResult .. sSubIndent .. sEntry
				end
			end
			sResult = sResult .. sIndent .. '}'
			return sResult
		end
	elseif sType == 'string' then
		return string.format('%q', t)
	elseif sType == 'number' or sType == 'boolean' or sType == 'nil' then
		return tostring(t)
	else
		error('Cannot serialize type ' .. sType, 0)
	end
end

local nativegetfenv = getfenv
if _VERSION == 'Lua 5.1' then
	-- If we're on Lua 5.1, install parts of the Lua 5.2/5.3 API so that programs can be written against it
	local nativeload = load
	local nativeloadstring = loadstring
	local nativesetfenv = setfenv
	function load(x, name, mode, env)
		if type(x) ~= 'string' and type(x) ~= 'function' then
			error('bad argument #1 (expected string or function, got ' .. type(x) .. ')', 2)
		end
		if name ~= nil and type(name) ~= 'string' then
			error('bad argument #2 (expected string, got ' .. type(name) .. ')', 2)
		end
		if mode ~= nil and type(mode) ~= 'string' then
			error('bad argument #3 (expected string, got ' .. type(mode) .. ')', 2)
		end
		if env ~= nil and type(env) ~= 'table' then
			error('bad argument #4 (expected table, got ' .. type(env) .. ')', 2)
		end
		if mode ~= nil and mode ~= 't' then
			error('Binary chunk loading prohibited', 2)
		end
		local ok, p1, p2 =
			pcall(
			function()
				if type(x) == 'string' then
					local result, err = nativeloadstring(x, name)
					if result then
						if env then
							env._ENV = env
							nativesetfenv(result, env)
						end
						return result
					else
						return nil, err
					end
				else
					local result, err = nativeload(x, name)
					if result then
						if env then
							env._ENV = env
							nativesetfenv(result, env)
						end
						return result
					else
						return nil, err
					end
				end
			end
		)
		if ok then
			return p1, p2
		else
			error(p1, 2)
		end
	end
	table.unpack = unpack
	table.pack = function(...)
		return {n = select('#', ...), ...}
	end
end

_G.textutils = {
	serialize = function(t)
		--https://github.com/dan200/ComputerCraft/blob/master/src/main/resources/assets/computercraft/lua/rom/apis/textutils.lua
		local tTracking = {}
		return serializeImpl(t, tTracking, '')
	end,
	unserialize = function(s)
		--https://github.com/dan200/ComputerCraft/blob/master/src/main/resources/assets/computercraft/lua/rom/apis/textutils.lua
		if type(s) ~= 'string' then
			error('bad argument #1 (expected string, got ' .. type(s) .. ')', 2)
		end
		local func = load('return ' .. s, 'unserialize', 't', {})
		if func then
			local ok, result = pcall(func)
			if ok then
				return result
			end
		end
		return nil
	end
}
