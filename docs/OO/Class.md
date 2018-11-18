# Class

Note: its important to clearly document functionality, but for brevity repeated comments are not included in the examples below.

## Creating Classes

When creating a class, its important to set the `ClassName` property (used for debugging and tostring). If you forget, a warning will print every time an instance of that class is created.

### `Class()`

Creates a new independent class.

### `Class(parent: Class)`

Creates a new class that inherits from parent.

### `Class(interfaces...: Inteface)`

Creates a new class that should implement the given interfaces. See the Interface docs for information on how interfaces work.

### `Class(parent: Class, interfaces...: Inteface)`

Creates a new class that inherits from `parent` and should implement the given interfaces.

## Creating instances

### `MyClass(args...)`

Instantiates an object. All arguments are passed to the constructor

```LUA
--[[
    An example class
]]
MyClass = Class()
MyClass.ClassName = 'MyClass'

obj = MyClass()
```

### `MyClass.convertToInstance(tbl: table, args...)`

Attaches the class information to an existing table. Normally when creating instances, a new table is created for the object, this allows you to use an existing table. Note: this will change / set the metatable on the given table.

Since converting a table modifies the table itself, you may want to use `cloneTable` to avoid changing the original.

This is useful when you'd like to easily wrap an existing object with some additional functionality, such as the result from `turtle.getItemDetail()`.

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

function MyClass:printName()
    print(self.name)
end

obj = MyClass.convertToInstance(turtle.getItemDetail())

obj:printName()
```

## Special class properties

### `MyClass:constructor()`

The class constructor is a function invoked on a new objects when they are created. All invocation arguments will be passed to the constructor. The default constructor simply calls the parent constructor, if there is one.

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

--[[
    name: string - Sets the name of this object
]]
function MyClass:constructor(name)
    self._name = name
end

obj = MyClass('My Object')
```

### `MyClass:conversionConstructor()`

The class conversion constructor is a function invoked on a existing objects when they are converted to an instance of this class. Like the normal constructor, all invocation arguments will be passed to the conversion constructor. The default constructor simply calls the parent constructor, if there is one.

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

function MyClass:constructor(message)
    self.message = message
end

function MyClass:conversionConstructor()
    self.message = self.data1
end

function MyClass:conversionConstructor()
    self.message = self.data1
end

function MyClass:speak()
    print(self.message)
end

obj = {
    data1 = 'bork'
}
MyClass.convertToInstance(obj)

obj2 = MyClass('bark')

obj:speak()
obj2:speak()
```

### `MyClass:toString()`

Called when objects are passed to the `tostring` (or `print`) methods. Passing `self` to `tostring` again inside the classes `:toString` will invoke LUA's default `tostring` handler.

The default `toString` method returns the objects `ClassName` followed by the table id from LUA's native tostring method.

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

function MyClass:constructor(name)
    self._name = name
end

function MyClass:toString()
    return 'MyClass named ' .. self._name
end

obj = MyClass('My Object')

print(obj)
--> MyClass named My Object
```

### `MyClass:isEqual(other: self)`

Called when two objects _of the same type_ (that is, they share a metatable) are compared using `==`. It is not called if an object is compared to itself, or to a different type of value.

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

function MyClass:constructor(name)
    self._name = name
end

function MyClass:isEqual(other)
    print('Custom isEqual called')
    return other._name == self._name
end

a = MyClass('a')
b = MyClass('b')
a2 = MyClass('a')
fakeA = {
    _name = 'a'
}

print(a == b)
--> Custom isEqual called
--> false

print(a == a2)
--> Custom isEqual called
--> true

print(a == a)
--> true

print(a == fakeA)
--> false
```

## Object helper functions

### `MyClass:getType()`

Returns the class object used to create this object.

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

obj = MyClass()

print(obj:getType() == MyClass)
--> true
```

### `MyClass:isType(classOrInterface: Class | Interface)`

Returns true if this class extends or implements the given class or interface

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

MySubclass = Class(MyClass)
MySubclass.ClassName = 'MySubclass'

OtherClass = Class()
OtherClass.ClassName = 'OtherClass'

obj = MySubclass()

print(obj:isType(MySubClass))
--> true

print(obj:isType(MyClass))
--> true

print(obj:isType(OtherClass))
--> false
```

### `MyClass.isOrInherits(classOrInterface: Class | Interface)`

Works almost the same as `:isType` but is a static method to be called from the class type rather than an instance.

```LUA
MyClass = Class()
MyClass.ClassName = 'MyClass'

MySubclass = Class(MyClass)
MySubclass.ClassName = 'MySubclass'

OtherClass = Class()
OtherClass.ClassName = 'OtherClass'

print(MySubclass.isOrInherits(MySubClass))
--> true

print(MySubclass.isOrInherits(MyClass))
--> true

print(MySubclass.isOrInherits(OtherClass))
--> false
```

### `MyClass:assertImplementation()`

This is a helper method that you probably won't need to call yourself, since its called automatically when the first instance of a class is created.

It iterates all interfaces that this class is supposed to implement, and throws an error if any properties are missing or of the incorrect type.

See the Interface docs for examples.
