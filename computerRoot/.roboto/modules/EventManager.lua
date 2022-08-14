EventManager = Class()
EventManager.ClassName = 'EventManager'

function EventManager:constructor()
	self._handlers = {}
	self._suppress = false
end

EventManager.AbortSignal = Class()
EventManager.AbortSignal.ClassName = 'EventManager.AbortSignal'

function EventManager.AbortSignal:constructor()
	self._aborted = false
	self._abortHandlers = {}
end

function EventManager.AbortSignal:abort()
	if (not self._aborted) then
		self._aborted = true
		for _, handler in ipairs(self._abortHandlers) do
			pcall(handler)
		end

		self._abortHandlers = nil
	end
end

function EventManager.AbortSignal:onAbort(handler)
	if (self._aborted) then
		pcall(handler)
	else
		table.insert(self._abortHandlers, handler)
	end
end

function EventManager.AbortSignal:wasAborted()
	return self._aborted
end

function EventManager:on(event, handler, abort)
	assertType(event, 'string')
	assertType(handler, 'function')

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
	assertType(event, 'string')
	assertType(handler, 'function')

	local wrapper

	wrapper = function(...)
		self:off(event, wrapper)
		handler(...)
	end

	self:on(event, wrapper, abort)
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
