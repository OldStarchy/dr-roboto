--Startlocal and endlocal are used to prevent all the classes below from polluting the global namespace

startlocal()

-- loaded =
-- 	pcall(
-- 	function()
--[[ Required Classes ]]
include 'Go/Action'
include 'Go/ActionInvocation'
include 'Go/ActionResult'

--[[ Actions ]]
include 'Go/Sequence'
include 'Go/FunctionAction'
include 'Go/MoveAction'
include 'Go/FindAction'
include 'Go/ItemAction'
include 'Go/AttachmentAction'

--[[ Go ]]
include 'Go/Go'

go = Go()
include 'Go/Actions'
-- 	end
-- )

local module = endlocal()
return module.go
