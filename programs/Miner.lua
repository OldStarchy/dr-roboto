local Miner = {}

function Miner.needleMine(tracker)
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
