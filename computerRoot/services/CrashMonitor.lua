while (true) do
	local e, id, name = os.pullEventRaw(ProcessManager.PROCESS_CRASHED)
	log.warn('Process ' .. tostring(id) .. ' "' .. tostring(name) .. '" has crashed')
end
