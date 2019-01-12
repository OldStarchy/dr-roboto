EventManager = Class()
EventManager.ClassName = 'EventManager'

function EventManager:constructor()
	self._handlers = {}
end

function EventManager:on(event, handler)
	assertType(event, 'string')
	assertType(handler, 'function')

	if (self._handlers[event] == nil) then
		self._handlers[event] = {}
	end

	local handlers = self._handlers[event]

	if (handlers[handler] ~= nil) then
		return
	end

	table.insert(handlers, handler)
	handlers[handler] = #handlers
end

function EventManager:off(event, handler)
	assertType(event, 'string')

	if (handler == nil) then
		self._handlers[event] = nil
	end

	assertType(handler, 'function')

	local handlers = self._handlers[event]
	if (handlers == nil) then
		return
	end

	local pos = handlers[handler]

	if (pos == nil) then
		return
	end

	table.remove(handlers, pos)
	handlers[handler] = nil
end

function EventManager:trigger(event, ...)
	if (self._handlers[event] == nil) then
		return
	end

	local handlers = self._handlers[event]
	if (handlers == nil) then
		return
	end

	local result = {}

	for i, handler in ipairs(handlers) do
		result[i] = {handler(...)}
	end

	return result
end
