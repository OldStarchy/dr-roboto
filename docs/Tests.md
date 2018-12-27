# Tests

In this project there is a fairly robust unit testing framework. The goal is to easily confirm that after changes have made, nothing broke. This is especially important when dealing with merges and refactoring.

## The Test Environment

Each test is run in a ([mostly](https://github.com/aNickzz/dr-roboto/issues/2)) sandboxed environment. A few dummy classes are created to prevent the turtle from going a-wal while running tests, then all normal dependencies are loaded. Once everything is loaded, the `fs` api is replaced with an in-memory Virtual File System, this prevents tests from creating any real files and leaving a mess. One test is then run, it is logged according to the logging level in effect, then the environment (and VFS) is scrapped before a new one is created for the next test.

This way, changes to the global environment are isolated per test (eg. the creation of global variables, and files) don't cause cross-test contamination.

## Creating Test Files

Test files are found automatically by the framework. For a test file to be run, it must be directly inside a folder named `tests` and its full name must end with `Test.lua` (eg. `Navigation/tests/PositionTest.lua`).

Each test file will typically contain one call to the `test` function. The test function takes a namespace, and a table of tests. The is a named list of either test functions, or further namespaced test tables.

```LUA
test(
    'Example Tests',
    {
        ['First test'] = function(t)
            print('this is "Example Tests.First Test"')
        end,
        ['Second test'] = function(t)
            print('this is "Example Tests.Second Test"')
        end,
        ['Sub Namespace'] = {
            ['First test'] = function(t)
                print('this is "Example Tests.Sub Namespace.First Test"')
            end,
            ['Something Else'] = function(t)
                print('this is "Example Tests.Sub Namespace.Something Else"')
            end
        }
    }
)
```

## Writing Tests

Test functions take one parameter (commonly `t`) which is unimaginatively named the "test parameter". The test parameter contains a number of assert functions. Each test must call at least one `t.assertX` function.

A test should test one piece of functionality (not necessarily one function) eg. "A crafting recipe added to a book can be retrieved from the book by name".

```LUA
test(
    'RecipeBook',
    {
        ['crafting find by name'] = function(t)
            local book = RecipeBook()

            local recipeName = 'something'
            local recipe = CraftingRecipe(recipeName, {}, 1)

            book:add(recipe)

            local retrieved = book:findCraftingRecipeByName(recipeName)

            t.assertEqual(retrieved, recipe)
        end,
    }
)
```

> ### Note
>
> Tests are not run in the order they are defined; since they're stored in tables, the order depends on how the `paires` (aka `next`) function iterates. This should not matter as each test is isolated, but it just means that the order of execution is undefined.

Every test should test something specific, but if the only condition for a test to pass is that it doesn't throw an error (eg. testing that a constructor works), you should call `t.assertFinished()`. Not doing so will cause the test to fail.

## The "Test Parameters" API

The assert functions in this api work by throwing an error if a condition is not met, with a detailed message regarding the failure.

### `t.assertEqual(result, expected)`

Checks that `result` is literally `==` to `expected`.

### `t.assertNotEqual(result, unexpected)`

The opposite of the above.

### `t.assertTableEqual(result, expected)`

Recursively checks if two tables are equivalent, giving information about which key/value differed if they are not equal.

### `t.assertThrows(method, ...)`

Calls `method` with the given args `...` and passes if `method` throws an exception.

### `t.assertNotThrows(method, ...)`

Calls `method` (as above) but fails the test if it does throw an exception. This is pretty much the same as just running `method` as is, since throwing an exception normally will also fail the test.

### `t.assertCalled()`

Returns a dummy function that must be called before the test finishes. The dummy function takes any arguments and returns nil.

### `t.assertCalledWith(...)`

Returns a dummy function that must be called with the given arguments `...`. Each argument is checked using the `==` operator.

### `t.assertNotCalled()`

Returns a dummy function that will fail the test when called.

### `t.assertFinished()`

Call this at the end of your test if you haven't called any of the above functions.

### `t.mock(name: string, retVals: table = {nil}, doPrint: bool = true, stackLevels: int = 1): table`

Creates a mock object (using `t.mockCustom`) whos properties will always be a function that returns `unpack(retVals)`. For example

```LUA
local dummyTerm = t.mock('test object', {5, 2}, true, 2)

local w, h = dummyTerm.getSize()
-- w == 5 and h == 2

local a, b = dummyTerm.thisIsJustADummyObject('potato')
-- a == 5 and b == 2
```

If `doPrint` is true, then any mock functions print when they are called (and with what parameters), and if `stackLevels` > 0, a stacktrace is also printed (showing where the function was called).

### `t.mockCustom(index, newIndex): table`

A short-cut function for creating a table with its metatable's `__index` and `__newindex` properties set. Do some research on [LUA metatables](https://www.lua.org/pil/13.4.1.html) if you want to learn what this means.

## Running the tests

To run the tests, you should invoke the `test.lua` file, usually by running `dofile('test.lua')()`. The file takes two optional arguments, `logLevel`, and `filter`. A log level is any one of `0`, `1`, or `2`.

-   `0`: Only a summary is printed to the terminal
-   `1`: Tests that fail are logged to the terminal, along with a summary.
-   `2`: All tests are logged, along with a summary.

The filter is pattern used to match against a tests full namespace. eg. `'*Block*Constructor'` will match `'FurnaceBlock.EmptyConstructor'` and `'Blocker.Constructor'` but not `'OtherThing.SomethingElse'`.
