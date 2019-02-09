# Event Manager

An object for handling event triggering.
Should be attached to an objects `ev` property for consistency.

Events are identified by a plain string. There's no conventions for what the events should be called but following computercrafts `os.pullEvent` events, they should probably be something like `turtle_moved` or `key_up`.

If it is required, we can implement a `:one(event: string, handler: function)` function that will attach a handler that removes itself after being called once.

## Methods

### `:on(event: string, handler: function)`

Adds a handler for a particular event. If the handler is already attached to the event, it won't get added again.

### `:off(event: string, handler?: function)`

If `handler` is `nil` it will remove all handlers for an event. If `handler` is given, only it is removed.
If the given handler is not already attached to the event, nothing happens.

### `:trigger(event: string, ...args: any): result[]`

Executes all handlers attached to the given `event`. All extra arguments are passed to the handler function.

The results returned by each handler are returned in a list, this way you can use the result for whatever. See example below.

## Example

```LUA
mov.ev:on('turtle_moved', function(pos)
    if (turtle.getFuelLevel() < 100) then
        print('Running out of fuel')
    elseif (turtle.getFuelLevel() < 50) then
        print('Only 50 fuel left!')
    end
end
```

```LUA
local privateThing = {
    ev = EventManager(),

    printSecretThing = function(username)

        local eventResults = self.ev:trigger('permission_check', username)

        --All handlers for 'permission_check' must return true
        for _, handlerResults in ipairs(eventResults) do

            --Check first return value
            if (handlerResults[1] ~= true) then
                print("not authorized")
                return
            end
        end

        print('Soylent Green is made from people.')
    end
}

privateThing.ev:on('permission_check', function(member)
    if (member == 'david') then
        return false
    end
end)

print('what is your name')
local name = read()

privateThing.printSecretThing(name)
```
