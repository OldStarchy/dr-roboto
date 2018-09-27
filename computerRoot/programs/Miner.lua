Miner = {}

function Miner.needleMine()
	Mov:push(true, true)

	local depth

	while (Mov:down()) do
		depth = depth + 1

		for i = 1, 4 do
			if (Inv:isNiceToHave(Inv:detect())) then
				turtle.dig()
			end

			Mov.turnRight()
		end
	end

	while (depth > 0) do
		Mov.up()
		depth = depth - 1
	end

	Inv:select(Inv.rubbishBlock)

	turtle.placeDown()

	Mov:pop()

	return true
end

function Miner.trackedNeedleMine(tracker)
	Mov:push(true, true)

	tracker:initVar('depth', 0)

	tracker:step(
		function(t1)
			while (Mov:down()) do
				t1:setVar('depth', t1:getVar('depth') + 1)

				t1:forITo(
					1,
					4,
					function(t2)
						if (Inv:isNiceToHave(Inv:detect())) then
							turtle.dig()
						end

						Mov.turnRight()
					end
				)
			end
		end
	)

	tracker:forITo(
		1,
		tracker:getVar('depth'),
		function(t1)
			Mov.up()
		end
	)

	Inv:select(Inv.rubbishBlock)

	tracker:step(turtle.placeDown)

	Mov:pop()

	return true
end
