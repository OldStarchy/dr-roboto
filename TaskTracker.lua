TaskTracker = Class()
TaskTracker.ClassName = 'TaskTracker'

function TaskTracker:constructor(state)
	self.head = 1
	self.steps = {}
	self.varsExist = {}
	self.vars = {}

	if (type(state) == 'table') then
		self.steps = state.steps
		self.varsExist = state.varsExist
		self.vars = state.vars
	end
end

function TaskTracker:getState()
	return {
		steps = self.steps,
		varsExist = self.varsExist,
		vars = self.vars
	}
end

function TaskTracker:initVar(name, value)
	if (self.varsExist[name]) then
		return
	end

	self.varsExist[name] = true
	self.vars[name] = value
end

function TaskTracker:setVar(name, value)
	self.varsExist[name] = true
	self.vars[name] = value
end

function TaskTracker:getVar(name)
	return self.vars[name]
end

function TaskTracker:_recordStep(step)
	self.head = self.head + 1
	table.insert(self.steps, step)
	return step
end

function TaskTracker:_getNextStep()
	return self.steps[self.head]
end

function TaskTracker:step(func)
	local step = self:_getNextStep()

	if (step == nil) then
		print('doing func first time')
		step =
			self:_recordStep(
			{
				name = 'func',
				completed = false
			}
		)
		step.result = {func(self)}
		step.completed = true
	elseif (step.completed) then
		print('skipping already completed func')
		self.head = self.head + 1
	else
		print('resuming func')
		self.head = self.head + 1
		step.result = {func(self)}
		step.completed = true
	end

	return unpack(step.result)
end

local shouldError = false
function trackTest(tracker)
	tracker:step(
		function(t1)
			print('Step 1')
			return true
		end
	)

	tracker:step(
		function(t1)
			print('Step 2')
			if (shouldError) then
				print('erroring')
				error()
			else
				print('not erroring')
			end
			return true
		end
	)
	tracker:step(
		function(t1)
			print('Step 3')
			return true
		end
	)
end

tracker = TaskTracker()
shouldError = true
pcall(trackTest, tracker)

--Forget step two was finished
print()
print('"rebooting"')
tracker = TaskTracker(tracker:getState())
shouldError = false
pcall(trackTest, tracker)
