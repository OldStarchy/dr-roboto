test(
	'EventManager',
	{
		['Basic'] = function(t)
			local ev = EventManager()

			local hdlr = t.assertCalled()

			ev:on('test', hdlr)

			ev:trigger('test')
		end,
		['Removed'] = function(t)
			local ev = EventManager()

			local hdlr = t.assertNotCalled()

			ev:on('test', hdlr)
			ev:off('test', hdlr)

			ev:trigger('test')
		end,
		['Multiple'] = function(t)
			local ev = EventManager()

			local hdlr = t.assertCalled()
			local hdlr2 = t.assertCalled()

			ev:on('test', hdlr)
			ev:on('test', hdlr2)

			ev:trigger('test')
		end,
		['None'] = function(t)
			local ev = EventManager()

			ev:trigger('test')

			t.assertFinished()
		end,
		['Other'] = function(t)
			local ev = EventManager()

			local hdlr = t.assertNotCalled()

			ev:on('something_else', hdlr)

			ev:trigger('test')
		end
	}
)
