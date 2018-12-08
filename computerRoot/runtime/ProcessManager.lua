local ProcMan = Class()
ProcMan.ClassName = 'ProcessManager'

function ProcMan:constructor()
	self._processes = {}
	self._newProcesses = {}
	self._currentProcess = nil

	self._run = false
end

function ProcMan:_getProcessById(pid)
	for i, v in ipairs(self._processes) do
		if (v.id == pid) then
			return v, i
		end
	end

	return
end

function ProcMan:spawnProcess(func, name)
	assertType(func, 'function')
	name = assertType(coalesce(name, 'anon'), 'string')
	local co = coroutine.create(func)

	local proc = {
		name = name,
		coroutine = co,
		filter = nil,
		parent = self._currentProcess,
		id = {},
		eventQueue = {}
	}

	os.queueEvent('process.new', proc.id, proc.name)
	table.insert(self._newProcesses, proc)
	return proc.id
end

function ProcMan:getProcesses()
	local list = {}

	for _, v in ipairs(self._processes) do
		table.insert(
			list,
			{
				name = v.name,
				id = v.id,
				parent = v.parent
			}
		)
	end

	return list
end

function ProcMan:sendTerminate(pid)
	local proc = self:_getProcessById(pid)

	if (proc == nil) then
		return false
	end

	table.insert(proc.eventQueue, {'terminate'})

	return true
end

function ProcMan:wait(pid)
	local proc = self:_getProcessById(pid)

	if (proc == nil) then
		return false
	end

	while true do
		local _, epid = os.pullEvent('process.died')

		if (pid == epid) then
			return true
		end
	end
end

function ProcMan:run()
	self._run = true

	local eventData = {}

	while (#self._newProcesses > 0) do
		table.insert(self._processes, table.remove(self._newProcesses, 1))
	end

	while self._run and #self._processes > 0 do
		local n = 1
		while n <= #self._processes do
			local proc = self._processes[n]

			table.insert(proc.eventQueue, eventData)

			while (#proc.eventQueue > 0) do
				eventData = table.remove(proc.eventQueue, 1)

				if proc.filter == nil or proc.filter == eventData[1] or eventData[1] == 'terminate' then
					self._currentProcess = proc
					local ok, param = coroutine.resume(proc.coroutine, table.unpack(eventData))

					--TODO: handle crashed routine
					if not ok then
						error(param, 0)
					else
						proc.filter = param
					end

					if coroutine.status(proc.coroutine) == 'dead' then
						os.queueEvent('process.died', proc.id, proc.name)
						table.remove(self._processes, n)
						n = n - 1
						break
					end
				end
			end
			n = n + 1
		end

		while (#self._newProcesses > 0) do
			table.insert(self._processes, table.remove(self._newProcesses, 1))
		end

		eventData = {os.pullEventRaw()}
	end
end

--TODO: write api for kernal
function ProcMan:getAPI()
	local this = self
	local api = {}

	api.spawnProcess = function(...)
		return this:spawnProcess(...)
	end

	api.getProcesses = function(...)
		return this:getProcesses(...)
	end

	api.wait = function(...)
		return this:wait(...)
	end

	api.sendTerminate = function(...)
		return this:sendTerminate(...)
	end

	return api
end

return ProcMan
