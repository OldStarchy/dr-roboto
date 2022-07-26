local function tryRefuel(direction)
	if (inv:pushSelection('bucket')) then
		if (inv:hasEmpty()) then
			if (turtle['place' .. direction]()) then
				log:info('Refueled from lava source')
				inv:select('lava_bucket')
				turtle.refuel(1)
			end
		else
			log:info('No room to pick up lava for refueling')
		end
	end
	inv:popSelection()
end

local function digLayer()
	for i = 1, 4 do
		local itemInfront, detail = turtle.inspect()

		if (itemInfront) then
			log:info('found ' .. detail:getId())

			if (detail:matches('lava')) then
				if (detail.metadata == 0) then
					-- source block
					tryRefuel('Down')

					itemInfront, detail = turtle.inspect()
				end
			end

			if (itemInfront) then
				if (detail:isLiquid()) then
					log:info('liquid, blocking off')
					if (inv:pushSelection('cobblestone,dirt')) then
						turtle.place()
					else
						log:info('nothing to block it off with')
					end
					inv:popSelection()
				else
					local dig = true

					if (detail:matches('dirt') or detail:matches('grass')) then
						dig = inv:countItem('dirt') < 10
					elseif (detail:matches('stone:0,cobblestone')) then
						dig = inv:countItem('cobblestone') < 10
					end

					if (dig) then
						turtle.dig()

						--Check for flowing liquids that might have been released

						log:info('checking for flowing liquid')
						if (mov:getY() < 10) then
							log:info('waiting for lava')
							sleep(1.5)
						else
							sleep(0.5)
						end

						itemInfront, detail = turtle.inspect()
						if (itemInfront and detail:isLiquid()) then
							if (inv:pushSelection('cobblestone,dirt')) then
								turtle.place()
							else
								log:info('nothing to block it off with')
							end
							inv:popSelection()
						end
					end
				end
			end
		end

		mov:turnRight()
	end
end

local function descend()
	local itemBelow, detail = turtle.inspectDown()
	if (not itemBelow) then
		return mov:down()
	end

	if (detail:matches('obsidian')) then
		return false
	end

	if (detail:matches('lava')) then
		if (detail.metadata == 0) then
			-- source block
			tryRefuel('Down')
		end
	end

	-- if (ask('Continue [Y|n]?', {'y', 'n'}, 'y') == 'n') then
	-- 	return false
	-- end

	if (not detail:matches('water')) then
		turtle.digDown()
	end

	return mov:down()
end

local function needleMine()
	local startHeight = mov:getY()

	while (descend()) do
		digLayer()
	end

	mov:push(true, true)
	nav:goToY(startHeight)
	mov:pop()
end

return needleMine
