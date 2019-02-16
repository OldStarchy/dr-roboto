local run = true
while (run) do
	local e, id, name = os.pullEventRaw(ProcessManager.PROCESS_CRASHED)
	if (e == 'terminate') then
		run = false
	else
		log.warn('Process ' .. tostring(id) .. ' "' .. tostring(name) .. '" has crashed')
	end
end
