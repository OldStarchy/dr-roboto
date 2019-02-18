StateSaver = Class()
StateSaver.ClassName = 'StateSaver'

function StateSaver.BindToFile(obj, filename, eventId)
	assertType(obj, 'table')
	assertType(obj.serialize, 'function', 'Object is not serializable')
	assertType(obj.ev, EventManager, "Object doesn't have an event manager")
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
