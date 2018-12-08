# Process Manager

The process manager is an api for creating and running multiple processes simultaniously. Each process is really just a glorified corotuines, and the process manager is just a wrapper around a list of coroutines with some helper functions.

To use this API you should have a good understanding of lua coroutines and read up on ComputerCrafts os.pullEvent.

## API

### `process.spawnProcess(func: function, name?: string): table`

Creates a process from the given function and returns the process id. This adds the process to a queue of new processes which will be added to the list of running processes once the current event finishes processing.

```LUA
local shellPid = process.spawnProcess(
    function()
        os.run(getfenv(), '/rom/programs/shell'))
    end,
    'shell')
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

There are two events emitted by the process manager, they can be pulled with `os.pullEvent`.

-   `process.new` emitted with `id: table, name: string`
-   `process.died` emitted with `id: table, name: string`

Maybe you can guess what they're for.

## TODO

Daemon processes that won't stop the computer from shutting down if they're still running

```LUA
process.spawnDaemon(rednet.run, 'rednet')
```
