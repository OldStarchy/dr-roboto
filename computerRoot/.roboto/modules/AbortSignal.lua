AbortSignal = Class()
AbortSignal.ClassName = 'AbortSignal'

function AbortSignal:constructor()
	local aborted = false
	local abortHandlers = {}

	function self:abort()
		if (not aborted) then
			aborted = true
			for _, handler in ipairs(abortHandlers) do
				pcall(handler)
			end

			abortHandlers = nil
		end
	end

	function self:onAbort(handler)
		if (aborted) then
			pcall(handler)
		else
			table.insert(abortHandlers, handler)
		end
	end

	function self:wasAborted()
		return aborted
	end
end
