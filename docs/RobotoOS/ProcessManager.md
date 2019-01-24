# Process Manager

The process manager is an api (backed by the `ProcessManager` class) for creating and running multiple processes simultaneously. Each process is really just a glorified coroutines, and the process manager is just a wrapper around a list of coroutines with some helper functions.

To use this API you should have a good understanding of lua coroutines and read up on ComputerCrafts os.pullEvent.

## Events

ComputerCraft has a built in event system which is used for all sorts of internals on how the computers and turtles work. These events include things like 'key_up' 'rednet_message' and other behind the scenes events used in functions like `turtle.dig`.

When an event is queued with `os.queueEvent(...)`, it can later be read with `os.pullEventRaw(filter)`. The process manager runs in an endless loop, reading an event, and passing it on to each process.

> Note:  
> `os.pullEvent(filter)` is a wrapper around `os.pullEventRaw(filter)` that will catch `terminate` events and throw an error.

> Another note:  
> `os.pullEventRaw(filter)` is actually just a wrapper around LUA's built in `coroutine.yield`, it provides no additional functionality. and is equivalent to just calling `coroutine.yield` directly.

## Event Cycle

### Example with a 'key' Event

1. The process manager calls `coroutine.yield` and gets suspended waiting for an event
2. A user presses a key.
3. The ComputerCraft module queues a `key` event (this is done in Java).
4. The process manager receives the event with `coroutine.yield` and resumes execution.
5. The process manager loops through all active processes and calls `coroutine.resume` with the event information.
6. Each process receives the `key` event information and does whatever it wants.
7. The process may invoke `process.spawnProcess`, doing so will add a new process to the pending list, and a `process.new` event is queued.
8. The process may crash, if it does, a `process.crashed` event is queued.
9. If the process is no longer running (finished or crashed) a `process.died` event is queued, and the process is removed from the list of active processes.
10. After all processes have received the event, new pending processes are added to the list of active processes (they don't receive the event)

## API

### `process.spawnProcess(func: function, name?: string, isDaemon?: bool): table`

Creates a process from the given function and returns the process id. This adds the process to a queue of new processes which will be added to the list of running processes once the current event finishes processing.

```LUA
local shellPid = process.spawnProcess(
    function()
        os.run(getfenv(), '/rom/programs/shell'))
    end,
    'shell'
)
```

### `process.wait(processId: table): boolean`

Pauses this process until the process with the given id terminates. This is the same as waiting for a `process.died` event with the given id, with the addition of first checking if a process with the given id actually exists.

Returns true if the process did exist, false otherwise.

```LUA
process.wait(shellPid)

print('shell finished')
```

### `process.getProcesses(): table`

Returns a list of all running processes' info. The list contains tables of the following form:

```LUA
{
    id: table --The id of the processi
    parent: table -- The id of the process that spawned this process (or nil if it was started by the OS)
    name: string -- The name of the process, if one was set, or 'anon'
}
```

```LUA
local procs = process.getProcesses()

for _,proc in ipairs(procs) do
    print(proc.id, proc.name)
end
```

### `process.sendTerminate(pid)`

Sends a 'terminate' event to a process. It will be added to the event queue for that process and it is up to the process to handle it accordingly.

```LUA
local dancePid = process.spawnProcess(function()
    while true do
        turtle.turnLeft()
        turtle.turnRight()
        turtle.forward()
        turtle.back()
        turtle.turnRight()
        turtle.turnLeft()
        turtle.forward()
        turtle.back()
    end
end)

print('Type \'stop\' to stop dancing')
while (read() ~= 'stop') do end

process.sendTerminate(dancePid)
process.wait(dancePid)

print('Stopped dancing')
```

## Events

There are three events emitted by the process manager, they can be pulled with `os.pullEvent`.

-   `process.new` emitted with `id: table, name: string`
-   `process.died` emitted with `id: table, name: string`
-   `process.crashed` emitted with `id: table, name: string`

Maybe you can guess what they're for.

## Daemon Processes

Daemon processes don't stop the computer from shutting down if they're still running.

```LUA
process.spawnProcess(
    rednet.run, --The function to call
    'rednet', --The name of the process
    true --is a daemon
)
```
