StateSaveable = Interface()
StateSaveable.serialize = 'function'
StateSaveable.ev = EventManager

StateSaver = Class()
StateSaver.ClassName = 'StateSaver'

function StateSaver.BindToFile(obj, filename, eventId)
	assertType(obj, StateSaveable)
	assertType(filename, 'string')
	eventId = assertType(coalesce(eventId, 'state_changed'), 'string')

	local saver = function()
		fs.writeTableToFile(filename, obj)
	end

	saver()

	obj.ev:on(eventId, saver)

	return {
		stop = function()
			obj.ev:off(eventId, saver)
		end
	}
end

return StateSaver
