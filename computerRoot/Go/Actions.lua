go:alias(
	{'debug', 'pause'},
	FunctionAction.GetFactory(
		function()
			go.pauseOnNext = true
		end
	)
)
go:alias({'f', 'forward', 'forwards'}, MoveAction.GetFactory(turtle.forward))
go:alias({'b', 'back', 'backward', 'backwards'}, MoveAction.GetFactory(turtle.back))
go:alias({'l', 'left'}, FunctionAction.GetFactory(turtle.turnLeft))
go:alias({'r', 'right'}, FunctionAction.GetFactory(turtle.turnRight))
go:alias({'u', 'up'}, MoveAction.GetFactory(turtle.up))
go:alias({'d', 'down'}, MoveAction.GetFactory(turtle.down))

go:alias({'D', 'dig'}, AttachmentAction.GetFactory(turtle.dig))
go:alias({'D^', 'digUp'}, AttachmentAction.GetFactory(turtle.digUp))
go:alias({'Dv', 'digDown'}, AttachmentAction.GetFactory(turtle.digDown))

go:alias({'P', 'place'}, FunctionAction.GetFactory(turtle.place))
go:alias({'P^', 'placeUp'}, FunctionAction.GetFactory(turtle.placeUp))
go:alias({'Pv', 'placeDown'}, FunctionAction.GetFactory(turtle.placeDown))

go:alias({'s', 'suck'}, ItemAction.GetFactory(turtle.suck))
go:alias({'s^', 'suckUp'}, ItemAction.GetFactory(turtle.suckUp))
go:alias({'sv', 'suckDown'}, ItemAction.GetFactory(turtle.suckDown))

go:alias({'S', 'drop'}, ItemAction.GetFactory(turtle.drop))
go:alias({'S^', 'dropUp'}, ItemAction.GetFactory(turtle.dropUp))
go:alias({'Sv', 'dropDown'}, ItemAction.GetFactory(turtle.dropDown))

go:alias({'Rf', 'redstoneFront'}, RedstoneAction.GetFactory('front'))
go:alias({'Rb', 'redstoneBack'}, RedstoneAction.GetFactory('back'))
go:alias({'Rl', 'redstoneLeft'}, RedstoneAction.GetFactory('left'))
go:alias({'Rr', 'redstoneRight'}, RedstoneAction.GetFactory('right'))
go:alias({'Ru', 'redstoneUp'}, RedstoneAction.GetFactory('up'))
go:alias({'Rd', 'redstoneDown'}, RedstoneAction.GetFactory('down'))

go:alias(
	{'m', 'mood'},
	function()
		local action = {
			mode = false,
			run = function(self, invoc)
				if (self.mode == 'angry') then
					mov.autoDig = true
					mov.autoAttack = true
				elseif (self.mode == 'nice') then
					mov.autoDig = false
					mov.autoAttack = false
				else
					print("m requires modifiers, either '?' to disable autodig, or '!' to enable it")
				end
				return ActionResult(self, true)
			end,
			mod = function(self, mod)
				if type(mod) == 'string' then
					if mod == '!' then
						self.mode = 'angry'
						return true
					end
					if mod == '?' then
						self.mode = 'nice'
						return true
					end
				end

				return false
			end
		}
		Action.constructor(action)
		return action
	end
)

-- Prints a string, but currently doesn't work well with the new running sourceMap printing
go:alias(
	{'L'},
	function()
		local action = {
			str = nil,
			run = function(self, invoc)
				local str =
					self.str or (type(invoc.previousResult.data) == 'string' and invoc.previousResult.data) or
					invoc.previousResult.success
				if not str then
					return ActionResult(self, false)
				end

				term.clearLine()
				print(str)

				return ActionResult(self, true, str)
			end,
			mod = function(self, mod)
				if type(mod) == 'table' then
					if mod.str then
						self.str = mod.str
						return true
					end
				end

				return false
			end
		}
		Action.constructor(action)
		return action
	end
)

go:alias(
	{'w', 'wait'},
	function()
		local action = {
			time = 1,
			run = function(self, invoc)
				sleep(self.time)
				return ActionResult(self, true, self.time)
			end,
			mod = function(self, m)
				if type(m) == 'number' then
					self.time = m
					return true
				end

				return false
			end
		}
		Action.constructor(action)
		return action
	end
)

go:alias(
	{'#', 'select'},
	function()
		local action = {
			run = function(self, invoc)
				if (self.findStr ~= nil) then
					local found = false

					while (not found) do
						for i = 1, 16 do
							if (turtle.getItemCount(i) > 0) then
								local name = turtle.getItemDetail(i).name
								local match = false

								if self.exact then
									match = name == self.findStr
								else
									match = string.find(name, self.findStr, 1, true)
								end
								if (match) then
									turtle.select(i)
									found = true
									break
								end
							end
						end

						if (self.optional) then
							break
						end
						if (not found) then
							term.clearLine()
							print('waiting for ' .. self.findStr)
							os.pullEvent('turtle_inventory')
						end
					end
					return ActionResult(self, found)
				end
				local s = self.index

				if self.incremental then
					s = turtle.getSelectedSlot() + s
				end

				if self.decremental then
					s = turtle.getSelectedSlot() - s
				end

				s = (s - 1) % 16 + 1

				turtle.select(s)
				return ActionResult(self, true, s)
			end,
			index = 1,
			incremental = false,
			decremental = false,
			findStr = nil,
			exact = false,
			optional = false,
			mod = function(self, m)
				if type(m) == 'number' then
					self.index = m
					return true
				end

				if type(m) == 'string' then
					if m == '+' then
						if self.decremental then
							inputError("Can't go up and down at the same time")
						end
						self.incremental = true
						return true
					end

					if m == '-' then
						if self.incremental then
							inputError("Can't go up and down at the same time")
						end
						self.decremental = true
						return true
					end

					if m == '~' then
						self.exact = true
						return true
					end

					if m == '?' then
						self.optional = true
						return true
					end
				end

				if type(m) == 'table' then
					self.findStr = m.str
					return true
				end

				return false
			end
		}
		Action.constructor(action)
		return action
	end
)
go:alias({'F', 'find'}, FindAction.GetFactory(turtle.inspect))
go:alias({'F^', 'findUp'}, FindAction.GetFactory(turtle.inspectUp))
go:alias({'Fv', 'findDown'}, FindAction.GetFactory(turtle.inspectDown))
go:alias({'a', 'attack'}, AttachmentAction.GetFactory(turtle.attack))
go:alias({'a^', 'attackUp'}, AttachmentAction.GetFactory(turtle.attackUp))
go:alias({'av', 'attackDown'}, AttachmentAction.GetFactory(turtle.attackDown))
go:alias(
	{'help'},
	function()
		local action = {
			run = function(self)
				local helpText =
					[[g is for go

  For stringing together all kinds of actions easily, even if somewhat confusingly.

  Use keywords
  ]]
				-- And the winner for the most confusing variable name goes to
				-- ...
				-- ...
				-- factionKeys!
				for i, v in pairs(go.factionKeys) do
					helpText = helpText .. '  ' .. table.concat(v, ', ') .. '\n'
				end
				helpText =
					helpText ..
					[[

  and modifiers,
    ?   to continue on failure
    X   to repeat X times
    *   to repeat infinitley

  group actions with ( and ) and use
    L   to log text


  Examples:
    Dig all the way down
      g (Dvd)*
      g (digDown down)*
    Build bridge / tunnel
      g (D^Dpv?)*
      g (digUp dig placeDown?)*
    Attack while spinning
      g (ar)*
      g (attack right)*
    The Pain dance:
      g L'Dancing'((fabrfabl)2L'ohh'u(ra)4dL'rocking it!'r4)*
      g L'Dancing'((forward attack back right forward attack back left)2 L'ooh' up (right attack)4 down L'rocking it!' right4)*
    Dig a 3x3 tunnel
      g (((Df)! Pv? l(D?f)!Pv?b (D^?u)! D? (D^?u)! D?r2 D? d D? d (Df)!Pv?b l)7 ((Df)! Pv?l(D?f)!Pv?b (D^?u)! D? #16P?#1 (D^?u)! D?r2 D? d D? d (Df)!Pv?b l))?*

  Speak to OldStarchy for bug reports and feature requests]]
				textutils.pagedPrint(helpText)
				return ActionResult(self, true)
			end
		}
		Action.constructor(action)
		return action
	end
)
