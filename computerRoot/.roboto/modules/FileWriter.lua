FileWriter = Class()
FileWriter.ClassName = 'FileWriter'

function FileWriter:constructor(fileName)
	assertType(fileName, 'string')
	self.maximumLogCount = 10
	self._fileName = fileName

	local path = fs.getDir(fileName)
	if (not fs.exists(path)) then
		fs.makeDir(path)
	end

	self:shuffleBackups()

	self._file = fs.open(self:_compileName(fileName, 0, 'log'), 'w')
	self._widest = 3
end

function FileWriter:shuffleBackups()
	local extension = 'log'
	local name = self._fileName

	function backup(n)
		local oldName = self:_compileName(name, n, extension)
		local newName = self:_compileName(name, n + 1, extension)

		if (n >= self.maximumLogCount) then
			fs.delete(oldName)
			return
		end

		if (fs.exists(newName)) then
			backup(n + 1)
		end

		fs.move(oldName, newName)
	end

	if (fs.exists(self:_compileName(self._fileName, 0, extension))) then
		backup(0)
	end
end

function FileWriter:_compileName(base, index, extension)
	return base .. '.' .. index .. '.' .. extension
end

function FileWriter:log(typ, message, frameInfo)
	local proc = process and process.getCurrentProcess()
	if (proc) then
		local char = ':'
		if (proc.daemon) then
			char = '_'
		end

		local prefix = proc.name .. ' (' .. proc.id .. ')'
		if (#prefix > self._widest) then
			self._widest = #prefix
		end

		self._file.write(stringutil.lPad(prefix, self._widest) .. char .. ' ' .. message .. '\n')
	else
		self._file.write(stringutil.lPad('[0]', self._widest) .. ': ' .. message .. '\n')
	end
	self._file.flush()
end
