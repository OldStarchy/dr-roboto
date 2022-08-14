EventManager = Class()
EventManager.ClassName = 'EventManager'

function EventManager:constructor()
	self._handlers = {}
	self._suppress = false
end

function EventManager:on(event, handler, abort)
	assertParameter(event, 'event', 'string')
	assertParameter(handler, 'handler', 'function')
	assertParameter(abort, 'abort', AbortSignal, 'nil')

	if (self._handlers[event] == nil) then
		self._handlers[event] = {}
	end

	local handlers = self._handlers[event]

	if (handlers[handler] == nil) then
		table.insert(handlers, handler)
		handlers[handler] = #handlers
	end

	local this = self
	local function off()
		this:off(event, handler)
	end

	if (abort ~= nil) then
		abort:onAbort(off)
	end

	return off
end

function EventManager:one(event, handler, abort)
	assertParameter(event, 'event', 'string')
	assertParameter(handler, 'handler', 'function')
	assertParameter(abort, 'abort', AbortSignal, 'nil')

	local wrapper

	wrapper = function(...)
		self:off(event, wrapper)
		handler(...)
	end

	self:on(event, wrapper, abort)
end

function EventManager:off(event, handler)
	assertParameter(event, 'event', 'string')
	assertParameter(handler, 'handler', 'function', 'nil')

	if (handler == nil) then
		self._handlers[event] = nil
	end

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
	self._suppress = assertParameter(suppress, 'suppress', 'boolean')
end

function EventManager:trigger(event, ...)
	assertParameter(event, 'event', 'string')

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
