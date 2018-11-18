# Global OO helper functions

## `isType(obj: any, typ: string | Class | Interface): boolean`

Checks if an object implements a class, an interface, or is of a particular type (eg. 'function').

In addition to the following built in LUA types

-   `'nil'`
-   `'boolean'`
-   `'number'`
-   `'string'`
-   `'userdata'`
-   `'function'`
-   `'thread'`
-   `'table'`

two more are defined as follows

-   `'int'` must be a whole number and
-   `'char'` must be a string of length 1

```LUA
IMyInterface = Interface()

IMyInterface2 = Interface()
IMyInterface2.thing = 'function'

MyClass = Class()
MyClass.ClassName = 'MyClass'

isType(3.14, MyClass)
--> false

isType(3.14, 'int')
--> false

isType(3.14, 'number')
--> true

obj = MyClass()

isType(obj, 'string')
--> false

isType(obj, MyClass)
--> true

-- NOTE: the below interface tests are planned but not yet implemented.
isType(obj, IMyInterface)
--> true

isType(obj, IMyInterface2)
--> false

isType({
    thing =, IMyInterface2)
--> false
```

## `assertType(obj: any, typ: string | Class | Interface, err?: string, frame?: int)`

Similar to `isType` but throws an exception if the type does not match. The `err` and `frame` parameters work the same way as the parameters of the built in `error` function.

Conversely, `assertType` _does_ implement both Class and Interface checks.

If the type does match, `obj` is returned.

```LUA
--[[
    Repeats a string a number of times.
]]
function repeatString(str, times)
    assertType(str, 'string')
    assertType(times, 'int')

    local r = ''

    while (times > 0) do
        r = r .. str
        times = times - 1
    end

    return r
end

print(repeatString('a', 2))
--> 'aa'

print(repeatString('a', 'b'))
--> throws: assertType failed "string" is not a "int"
```
