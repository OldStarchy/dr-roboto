ProcessManager = Class()
ProcessManager.ClassName = 'ProcessManager'

ProcessManager.PROCESS_DIED = 'process.died'
ProcessManager.PROCESS_NEW = 'process.new'
ProcessManager.PROCESS_CRASHED = 'process.crashed'

function ProcessManager:constructor()
	self._processes = {}
	self._newProcesses = {}
	self._currentProcess = nil

	self._run = false
	self._lastId = 0
end

function ProcessManager:_getNextId()
	self._lastId = self._lastId + 1
	return self._lastId
end

function ProcessManager:_getProcessById(pid)
	for i, v in ipairs(self._processes) do
		if (v.id == pid) then
			return v, i
		end
	end

	for i, v in ipairs(self._newProcesses) do
		if (v.id == pid) then
			return v, i
		end
	end

	return
end

function ProcessManager:spawnProcess(func, name, daemon)
	assertType(func, 'function')
	name = assertType(coalesce(name, 'anon'), 'string')
	daemon = assertType(coalesce(daemon, false), 'boolean')

	local co =
		coroutine.create(
		function()
			assert(runWithLogging(func))
		end
	)

	local proc = {
		name = name,
		coroutine = co,
		filter = nil,
		parent = self._currentProcess,
		id = self:_getNextId(),
		eventQueue = {},
		daemon = daemon
	}

	os.queueEvent(ProcessManager.PROCESS_NEW, proc.id, proc.name)
	table.insert(self._newProcesses, proc)

	return proc.id
end

function ProcessManager:getProcesses()
	local list = {}

	for _, v in ipairs(self._processes) do
		table.insert(
			list,
			{
				name = v.name,
				id = v.id,
				parent = (v.parent and v.parent.id) or nil,
				daemon = v.daemon
			}
		)
	end

	for _, v in ipairs(self._newProcesses) do
		table.insert(
			list,
			{
				name = v.name,
				id = v.id,
				parent = v.parent.id,
				daemon = v.daemon
			}
		)
	end

	return list
end

function ProcessManager:sendTerminate(pid)
	local proc = self:_getProcessById(pid)

	if (proc == nil) then
		return false
	end

	table.insert(proc.eventQueue, {'terminate'})

	return true
end

function ProcessManager:kill(pid)
	local proc = self:_getProcessById(pid)

	if (proc == nil) then
		return false
	end

	proc.killed = true

	return true
end

function ProcessManager:wait(pid)
	local proc = self:_getProcessById(pid)

	if (proc == nil) then
		return false
	end

	while true do
		local _, epid = os.pullEventRaw(ProcessManager.PROCESS_DIED)

		if (pid == epid) then
			return true
		end
	end
end

function ProcessManager:_countNonDaemon()
	local count = 0
	for _, proc in ipairs(self._processes) do
		if (not proc.daemon) then
			count = count + 1
		end
	end
	return count
end

function ProcessManager:run()
	self._run = true

	local eventData = {}

	while (#self._newProcesses > 0) do
		table.insert(self._processes, table.remove(self._newProcesses, 1))
	end

	while self._run and self:_countNonDaemon() > 0 do
		local n = 1
		while n <= #self._processes do
			local proc = self._processes[n]

			table.insert(proc.eventQueue, eventData)

			--While There are events for this process
			--		this process hasn't crashed or ended
			--		this process hasn't been killed
			while (#proc.eventQueue > 0 and coroutine.status(proc.coroutine) ~= 'dead' and not proc.killed) do
				local currentEventData = table.remove(proc.eventQueue, 1)

				if (proc.filter == nil or proc.filter == currentEventData[1] or currentEventData[1] == 'terminate') then
					self._currentProcess = proc
					local ok, param = coroutine.resume(proc.coroutine, table.unpack(currentEventData))
					self._currentProcess = nil

					if not ok then
						os.queueEvent(ProcessManager.PROCESS_CRASHED, proc.id, proc.name)
					else
						proc.filter = param
					end
				end
			end

			if (coroutine.status(proc.coroutine) == 'dead' or proc.killed) then
				os.queueEvent(ProcessManager.PROCESS_DIED, proc.id, proc.name)
				table.remove(self._processes, n)
			else
				n = n + 1
			end
		end

		while (#self._newProcesses > 0) do
			table.insert(self._processes, table.remove(self._newProcesses, 1))
		end

		eventData = {os.pullEventRaw()}
	end
end

function ProcessManager:getCurrentProcess()
	return self._currentProcess
end

--TODO: write api for kernal
function ProcessManager:createAPI()
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

	api.kill = function(...)
		return this:kill(...)
	end

	api.getCurrentProcess = function(...)
		return this:getCurrentProcess(...)
	end

	return api
end
