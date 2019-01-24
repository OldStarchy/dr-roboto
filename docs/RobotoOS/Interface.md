# Interface

Interfaces define a basic type specification for tables. They aren't hugely powerful due to the way LUA works, but they can help find implementation bugs.

## Creating Interfaces

### `Interface(parents?...: Interface)`

Create an interface that inherits the its spec from zero or more parents.

## Using Interfaces

### `MyClass = Class(IMyInterface)`

Classes can implement multiple interfaces by specifying the list of interfaces when the class is created. Interface implementations are only checked at runtime, which is normally when the first instance of a class type is created.

```LUA
IRunnable = Interface()
IRunnable.run = 'function'

MyClass = Class(IRunnable)
MyClass.ClassName = 'MyClass'

function MyClass:run()
    print('running')
end

obj = MyClass()
obj:run()


MyInvalidClass = Class(IRunnable)
MyInvalidClass.ClassName = 'MyInvalidClass'

obj = MyInvalidClass()
--> throws exception, MyInvalidClass[run] is nil not function
```

### `IMyInterface.test(obj)`

You can test arbitrary objects if they implement an interface.

```LUA
IRunnable = Interface()
IRunnable.run = 'function'


IRunnable.test({})
--> false

IRunnable.test({
    run = 3
})
--> false

IRunnable.test({
    run = function() end
})
--> true
```

### `IMyInterface.assertImplementation(obj)`

Similar to `.test` but will throw an exception with information about what part of the interface is missing from `obj`.

```LUA
IHasXYZ = Interface()
IHasXYZ.x = 'number'
IHasXYZ.y = 'number'
IHasXYZ.z = 'number'

function setPos(obj)
    IHasXYZ.assertImplementation(obj)

    self.x = obj.x
    self.y = obj.y
    self.z = obj.z
end
```

### `IMyInterface.isOrInherits(classOrInterface)`

Works the same way as `Class.isOrInherits`. Please refer to the doc for that function.

## Helper methods

### `Interface.FromObject(obj: table)`

Constructs an interface based on an existing object. Useful when you're trying to replace objects in other libraries but don't want to type out a definition for them. (Although the back and fourth between editor and error log may be more work anyway).

```LUA
ITerm = Interface.FromObject(term.getCurrent())

CustomTerm = Class(ITerm)
CustomTerm.ClassName = 'CustomTerm'

CustomTerm.assertImplementation()
```
