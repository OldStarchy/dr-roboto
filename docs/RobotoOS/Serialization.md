# Serialization

> Spelt with a 'z' for consistency

A class type is strictly serializable if it has

-   a `:serialize()` method that returns a table representation of the object
-   a corresponding static `.Deserialize()` function that can take the table and produce a new object
-   a `.ClassName` value set correctly which is used for looking up the class type when deserializing

## Functions

### `serialize(value: any): string`

Does almost exactly the same as the ComputerCraft's `textutils.serialize`, but includes special syntax for handling class objects.

### `deserialize(str: string): any`

Do I really need to write a description for this?

### `StateSaver.BindToFile(obj: serializable & monitorable, filename: string, eventId: string = 'state_changed'): {stop: () => void}`

`StateSaver` is a helper class designed to assist in persistence over reboots.

This function takes an object that matches the criteria above, as well as having matching `{ev: EventManager}`, a filename, and optionally the name of an event.

It will do 2 things:

1. Serialize the object and write it to the given filename
2. Subscribe to the `eventId` event (`'state_changed'` by default) event.
    - When the event is triggered, the object will be serialized to the file

The return value is a table containing a `stop` function that, when called, will unsubscribe the serializer effectively 'unbinding' the object from the file.

You can see this class in action [here](../../computerRoot/roboto/startup.lua#L33).

### `Class.LoadOrNew(file: string, class: Class, ...ctorArgs[]): class`

The counterpart to `StateSaver.BindToFile` is `Class.LoadOrNew`.

If the given file does not exist, a new instance of the given class is created using the given arguments.

If the file does exist it is read and deserialized. If the result is an instance of the requested class, it is returned, otherwise an error is thrown.

## Example

This is a fair mixed bag but you should be able to get what you need from here.

### `MyObj.lua`

```lua
MyObj = Class()
MyObj.ClassName = 'MyObj'


function MyObj.Deserialize(tbl)
    return MyObj(tbl.value)
end

function MyObj:serialize()
    return {
        value = self._value
    }
end

function MyObj:constructor(value)
    self.ev = EventManager()

    self:setValue(value)
end

function MyObj:setValue(value)
    assertType(value, 'number')

    if (value == self._value) then
        return
    end

    self._value = value;
    self._2xValue = value * 2

    self.ev:trigger('state_changed')
end
```

### `example.lua`

```lua
local obj = Class.LoadOrNew('myObj.tbl', MyObj, 4)
local tbl = obj:serialize()
local tblStr = serialize(tbl)
local objStr = serialize(obj)


print('-- obj')
print(obj)
print()

print('-- tbl')
print(tbl)
print()

print('-- MyObj.Deserialize(tbl)')
print(MyObj.Deserialize(tbl))
print()

print('-- tblStr')
print(tblStr)
print()

print('-- objStr')
print(objStr)
print()

print('-- deserialize(objStr)')
print(deserialize(objStr))

local stopToken = StateSaver.BindToFile(obj, 'myObj.tbl')
-- Creates / overwrites 'myObj.tbl' file

obj:setValue(6)
-- Overwrites 'myObj.tbl' file
```

### `myObj.tbl`

```lua
<MyObj|
    value = 6,
>
```

### Output

```lua
-- obj
MyObj: 1234abcd

-- tbl
table: 2345bcde

-- MyObj.Deserialize(tbl)
MyObj: 3456cdef

-- tblStr
{
    value = 4,
}

-- objStr
<MyObj|
    value = 4,
>

-- deserialize(objStr)
MyObj: 1234abcd
```
