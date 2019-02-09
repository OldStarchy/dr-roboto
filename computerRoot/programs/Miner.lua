Miner = {}

function Miner.needleMine()
	mov:push(true, true)

	local depth

	while (mov:down()) do
		depth = depth + 1

		for i = 1, 4 do
			if (inv:isNiceToHave(inv:detect())) then
				turtle.dig()
			end

			mov.turnRight()
		end
	end

	while (depth > 0) do
		mov.up()
		depth = depth - 1
	end

	inv:select(inv.rubbishBlock)

	turtle.placeDown()

	mov:pop()

	return true
end

function Miner.trackedNeedleMine(tracker)
	mov:push(true, true)

	tracker:initVar('depth', 0)

	tracker:step(
		function(t1)
			while (mov:down()) do
				t1:setVar('depth', t1:getVar('depth') + 1)

				t1:forITo(
					1,
					4,
					function(t2)
						if (inv:isNiceToHave(inv:detect())) then
							turtle.dig()
						end

						mov.turnRight()
					end
				)
			end
		end
	)

	tracker:forITo(
		1,
		tracker:getVar('depth'),
		function(t1)
			mov.up()
		end
	)

	inv:select(inv.rubbishBlock)

	tracker:step(turtle.placeDown)

	mov:pop()

	return true
end
