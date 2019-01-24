# OS Life Cycle

## TL;DR

Write your code in `mystartup.lua` (in `computerRoot`) (you may have to create it) and it will run on both PC and in ComputerCraft with all libraries loaded.

## Long version

1. The CraftOS `bios.lua` starts. This is the main entry point for all lua.
2. The bios starts either one of the `shell` or `multishell` programs, depending on the [settings](<http://computercraft.info/wiki/Settings_(API)>).
3. The shell starts by running the `startup` file in the computers root. This is the main entry point for any program we can write, and is when Dr. Roboto takes over.
4. The `startup` file checks to see if the code is running in ComputerCraft, or if its running on a PC natively.
5. If its running natively
    1. PC only polyfills are loaded from the `_polyfills` directory.
    2. The RobotoOS `roboto/os.lua` is run (Go to step 12)
6. Otherwise, `startup` checks to see if `shell` or `multishell` is running. If it is `multishell`, it changes the settings to disable `multishell` then reboots. (Go to step 1)
7. If Roboto is not already loaded (and it won't be the first time, see step 23)
8. Roboto overwrites the `os.run` and `os.shutdown`
   Rewriting `os.run` prevents the shutdown program from running [here](https://github.com/dan200/ComputerCraft/blob/e85cdacbc58dedacb7fcbb119efd2b44db4bcdd6/src/main/resources/assets/computercraft/lua/bios.lua#L864).
9. Roboto then calls `shell.exit` This causes `parallel.waitForAny` to exit early preventing the `rednet.run` coroutine from starting.
10. The bios then runs to completion, finally calling `os.shutdown` (which has been overwritten in step 5)
11. The original `os.run` and `os.shutdown` functions are restored.
12. `roboto/os.lua` is loaded and run in a protected environment that allows for basic error logging.
13. RobotoOS is now starting.
14. All the utility API's that don't immediately rely on the `Class` framework are loaded from `roboto/util`,
15. Various other core libraries are loaded (in order), this includes
    1. Some debugging helpers
    2. Modifications to the `fs` API to allow redirecton to `vfs`
    3. The Virtual File System (`vfs`) used by the tests later.
    4. LUA file loading functions.
    5. The Class framework associated helper functions.
    6. The "missing global" warning thing.
    7. The `log` api
    8. The `runWithLogging` helper function
    9. Finally, the `ProcessManager` class.
16. The global `ProcessManager` instance `process` is created.
17. The log files are initialized with the `log` api
18. `roboto/startup.lua` is run
    1. If running in ComputerCraft
        1. the startup tests are run (if not cancelled by a user)
    2. All API's that require persistent storage are loaded, this involves things like loading the current coordinates for the `Mov` API and recipes are loaded.
    3. If running on PC
        1. `mystartup.lua` is run. This is where you can put various temporary bits of code you want to run. (`mystartup.lua` is not stored in git because it is likely random bits of code for whatever you're currently working on)
        2. `roboto/startup.lua` then returns back to `roboto/os.lua`
        3. `roboto/os.lua` then exits and the program stops.
19. A daemon process for monitoring the current location and inventory is queued for starting (the process manager is not running yet)
20. The main `Hud` process is queued for starting in the process manager.
21. The process manager starts running.
22. The `Hud` starts the CraftOS `shell` program (this may later be replaced with a custom shell program)
23. `shell` runs the `startup` file again, but this time it runs steps 4, 5, 6, and 7 (stopping at 7).
24. The OS has finished loading and you can now start using the computer / turtle.
25. Once all non-daemon processes have died (or crashed) any error messages are shown (and logged to file) and finally...
26. The computer turns off.
