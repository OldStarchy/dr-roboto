test(
	'Log',
	{
		Info = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.INFO, t.assertCalledWith(message))

			log:info(message)
		end,
		Info2 = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.INFO, t.assertCalledWith(message))

			log:warning(message)
		end,
		Info3 = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.INFO, t.assertCalledWith(message))

			log:error(message)
		end,
		Warning = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.WARNING, t.assertNotCalled())

			log:info(message)
		end,
		Warning2 = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.WARNING, t.assertCalledWith(message))

			log:warning(message)
		end,
		Warning3 = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.WARNING, t.assertCalledWith(message))

			log:error(message)
		end,
		Error = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.ERROR, t.assertNotCalled())

			log:info(message)
		end,
		Error2 = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.ERROR, t.assertNotCalled())

			log:warning(message)
		end,
		Error3 = function(t)
			local message = 'this is some text'

			local log = Log(nil, Log.ERROR, t.assertCalledWith(message))

			log:error(message)
		end
	}
)
