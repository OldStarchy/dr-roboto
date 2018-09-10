go:alias({'f', 'forward', 'forwards'}, MoveAction.GetFactory(turtle.forward))
go:alias({'b', 'back', 'backward', 'backwards'}, MoveAction.GetFactory(turtle.back))
go:alias({'l', 'left'}, Action.GetFactory(turtle.turnLeft))
go:alias({'r', 'right'}, Action.GetFactory(turtle.turnRight))
go:alias({'u', 'up'}, MoveAction.GetFactory(turtle.up))
go:alias({'d', 'down'}, MoveAction.GetFactory(turtle.down))

go:alias({'D', 'dig'}, AttachmentAction.GetFactory(turtle.dig))
go:alias({'D^', 'digUp'}, AttachmentAction.GetFactory(turtle.digUp))
go:alias({'Dv', 'digDown'}, AttachmentAction.GetFactory(turtle.digDown))

go:alias({'P', 'place'}, Action.GetFactory(turtle.place))
go:alias({'P^', 'placeUp'}, Action.GetFactory(turtle.placeUp))
go:alias({'Pv', 'placeDown'}, Action.GetFactory(turtle.placeDown))

go:alias({'s', 'suck'}, ItemAction.GetFactory(turtle.suck))
go:alias({'s^', 'suckUp'}, ItemAction.GetFactory(turtle.suckUp))
go:alias({'sv', 'suckDown'}, ItemAction.GetFactory(turtle.suckDown))

go:alias({'S', 'drop'}, ItemAction.GetFactory(turtle.drop))
go:alias({'S^', 'dropUp'}, ItemAction.GetFactory(turtle.dropUp))
go:alias({'Sv', 'dropDown'}, ItemAction.GetFactory(turtle.dropDown))

go:alias(
	{'m'},
	function()
		return {
			mode = false,
			run = function(self, invoc)
				if (self.mode == 'angry') then
					Nav.autoDig = true
					Nav.autoAttack = true
				elseif (self.mode == 'nice') then
					Nav.autoDig = false
					Nav.autoAttack = false
				else
					print("m requires modifiers, either '?' to disable autodig, or '!' to enable it")
				end
				return ActionResult.new(self, true)
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
	end
)

go:alias(
	{'L'},
	function()
		return {
			str = nil,
			run = function(self, invoc)
				local str =
					self.str or (type(invoc.previousResult.data) == 'string' and invoc.previousResult.data) or
					invoc.previousResult.success
				if not str then
					return ActionResult.new(self, false)
				end

				print(str)

				return ActionResult.new(self, true, str)
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
	end
)

go:alias(
	{'w', 'wait'},
	function()
		return {
			time = 1,
			run = function(self, invoc)
				sleep(self.time)
				return ActionResult.new(self, true, self.time)
			end,
			mod = function(self, m)
				if type(m) == 'number' then
					self.time = m
					return true
				end

				return false
			end
		}
	end
)

go:alias(
	{'#', 'select'},
	function()
		return {
			run = function(self, invoc)
				local s = self.index

				if self.incremental then
					s = turtle.getSelectedSlot() + s
				end

				if self.decremental then
					s = turtle.getSelectedSlot() - s
				end

				s = (s - 1) % 16 + 1

				turtle.select(s)
				return ActionResult.new(self, true, s)
			end,
			index = 1,
			incremental = false,
			decremental = false,
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
				end

				return false
			end
		}
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
		return {
			run = function(self)
				local helpText =
					[[g is for go

  For stringing together all kinds of actions easily, even if somewhat confusingly.

  Use keywords
  ]]
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
      g L"Dancing"((fabrfabl)2L"ohh"u(ra)4dL"rocking it!"r4)*
      g L"Dancing"((forward attack back right forward attack back left)2 L"ooh" up (right attack)4 down L"rocking it!" right4)*
    Dig a 3x3 tunnel
      g (((Df)! Pv? l(D?f)!Pv?b (D^?u)! D? (D^?u)! D?r2 D? d D? d (Df)!Pv?b l)7 ((Df)! Pv?l(D?f)!Pv?b (D^?u)! D? #16P?#1 (D^?u)! D?r2 D? d D? d (Df)!Pv?b l))?*

  Speak to OldStarchy for bug reports and feature requests]]
				textutils.pagedPrint(helpText)
				return ActionResult.new(self, true)
			end
		}
	end
)
