EventManager = Class()
EventManager.ClassName = 'EventManager'

function EventManager:constructor()
	self._handlers = {}
	self._suppress = false
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

function EventManager:one(event, handler)
	assertType(event, 'string')
	assertType(handler, 'function')

	local wrapper

	wrapper = function(...)
		self:off(event, wrapper)
		handler(...)
	end

	self:on(event, wrapper)
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

function EventManager:suppress(suppress)
	self._suppress = assertType(suppress, 'boolean')
end

function EventManager:trigger(event, ...)
	if (self._suppress) then
		return {}
	end

	local handlers = self._handlers[event]
	if (handlers == nil) then
		return {}
	end

	local result = {}

	for i, handler in ipairs(handlers) do
		result[i] = {handler(...)}
	end

	return result
end
