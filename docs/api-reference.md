# Resourceful: API Reference

Resourceful offers a simple API for [acquiring](#acquiring-resources),
[requiring](#requiring-resources), and [defining](#configuration-resources)
project resources using a clean syntax with robust error handling.

```lua
local resources = require(script.Parent.Resourceful)
-- Acquire a resource named "HelperLib":
local HelperLib = resources.HelperLib
-- Require a resource named "MyLib":
local MyLib = resources.require.MyLib
```

Developers can define additional, dynamic resources by instantiating
Resourceful with
[custom configurations](#instantiating-resourceful-with-custom-configurations),
with further control of caching and error handling.

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  isCached = false,
  isStrict = false,
  resources = {
    HelperLib = function(resources, found)
      if game:GetService("RunService").isClient() then
        return found
      else
        return resources.ServerHelperLib
      end
    end,

    ServerHelperLib = function(resources, found)
      return game:GetService("ServerScriptService")
        :FindFirstChild("HelperLib", false)
    end,
  }})
```

## Acquiring Resources

Acquiring resources is as simple as instantiating Resourceful, and specifying
the name of the resource to be acquired.  Typical usage involves assigning the
result of `require(Resourceful)` to a variable, and using that variable as a
`table` to acquire resources.

<figure><figcaption><em>Example: Acquiring Resources</em></figcaption></figure>

```lua
local resources = require(script.Parent.Resourceful)
-- Acquire a resource named "HelperLib":
local HelperLib = resources.HelperLib

-- Using array notation to do the same thing:
HelperLib = resources["HelperLib"]

-- Using array notation with a variable to do the same thing:
local resourceName = "HelperLib"
HelperLib = resources[resourceName]
```

### Acquiring Resources With Default Behavior

If Resourceful is used with default behavior by using the function returned by
`require(Resourceful)` without further specifying a
[custom configuration](#instantiating-resourceful-with-custom-configurations),
Resourceful will search the parent of the `Resourceful Instance` for the first
immediate child `Instance` having the same name as the specified resource
name, throwing an error if the resource is not found.

### Acquiring Resources With Custom Behavior

Instantiating Resourceful with a
[custom configuration](#instantiating-resourceful-with-custom-configurations)
can:

- allow multiple `Instance` objects to be [searched](#configuration-search) when
looking for resources
- cause [missing resources to return nil](#configuration-isstrict) instead of
throwing an error
- invoke [custom resource loaders](#configuration-resources) to return specified
values for each resource, or execute a function to acquire resources on-demand
- enable or disable [caching of resources](#configuration-iscached)
- invoke [error handlers](#configuration-onerror) or
[error events](#configuration-onerrorevent) when errors are encountered

### Requiring Resources

Prefixing a resource name with `require` will cause the specified resource to
be acquired and then passed to the Lua function `require`:

```lua
local resources = require(script.Parent.Resourceful)
-- Require a resource named "MyLib":
local MyLib = resources.require.MyLib
-- Same as:
MyLib = require(resources.MyLib)
```

If an error occurs when invoking the `require` function, Resourceful will wrap
the error in Resourceful's own error message, and throw it.  Resourceful will
also throw a descriptive error if the specified resource is not a
`ModuleScript`.

## Instantiating Resourceful with Custom Configurations

Resourceful can be invoked with custom configuration options to define
additional resources and behavior for acquiring resources.

Configuration options are specified by passing a `table` of options to the
`Resourceful` method.

<figure><figcaption><em>Example: Custom Configurations</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local configOptions = {
  -- Custom configuration options go here
}

-- Create an instance of Resourceful with custom behavior:
local resources = Resourceful(configOptions)

local otherConfigOptions = {
  -- An example of other custom configuration options
}

-- Multiple instances of Resourceful, each with customized behavior, can be
-- used simultaneously.
local otherResources = Resourceful(otherConfigOptions)

-- Using the customized Resourceful instance:
local MyHelperLib = resources.require.MyHelperLib

-- Using the other customized Resourceful instance:
local ThirdPartyLib = otherResources.require.ThirdPartyLib
```

### Configuration: name

`name` is a `string` parameter reported in errors thrown by Resourceful, and
presently has no other use. Defaults to `"script"` in error messages.

<figure><figcaption><em>Example: name</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({ name = "MyLib" })
```

If you are writing libraries to be shared with others, specifying a `name`
when using Resourceful can help users of your libraries to more easily
identify and troubleshoot resource issues within your libraries.

### Configuration: search

`search` is an `Instance` object, or `table` of one or more `Instance`
objects, to be searched when acquiring resources.  If multiple `Instance`
objects are specified within a `table`, they are searched in the order in
which they are specified.  Defaults to the `Parent` of the Resourceful
`Instance`.

Searching is performed by executing `:FindFirstChild(resourceName, false)` on
each search target, where `resouceName` is the `string` name of the resource
to be found, and `false` directs Roblox to search only the immediate children
of the search targets, and not deeper descendants.

<figure><figcaption><em>Example: search</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({ search = {
  script.Parent,
  script.Parent.Parent,
  game:GetService("ReplicatedStorage"):FindFirstChild("Scripts", false)}})

-- Resourceful searches for "Helpers" in the following locations:
-- script.Parent.Helpers
-- script.Parent.Parent.Helpers
-- game:GetService("ReplicatedStorage").Scripts.Helpers
local Helpers = resources.Helpers
```

### Configuration: resources

`resources` is a `table` parameter that allows custom resources of any data
type to be defined and made available for acquisition.

The name of each element within `resources` corresponds to the name of a
resource that can be acquired, and the value assigned to the element
corresponds to the value of the resource.

<figure><figcaption><em>Example: resources</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {
    boolResource = true,
    numResource = 3.14,
    strResource = "hello",
    tableResource = { value = true },
    functionResource = function(resources, found)
      return function(name) return ("Hi, %s!"):format(name) end
    end,
  }})

print(resources.boolResource) -- true
print(resources.numResource) -- 3.14
print(resources.strResource) -- "hello"
print(resources.tableResource.value) -- true
print(resources.functionResource("person")) -- "Hi, person!"
```

#### Non-function Resources

Resources that are assigned a data type other than `function` are returned
immediately by Resourceful whenever the resource is requested.  In this case,
Resourceful will not search for similarly named `Instance` children located
within the defined [search path](#configuration-search).

#### Resource Functions

For each custom resource that is assigned a data type of `function`, the
function is not returned as the value of the resource; instead, the function
is executed, and its return value is used as the value of the resource.

<figure><figcaption><em>Example: Resource Function, Simple</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {
    number = function(resources, found)
      return math.random(100)
    end,
  }})

print(resources.number) -- 41
print(resources.number) -- 41 again, because caching is enabled
```

##### Resource Function Execution

By default, the result of a resource function is cached, so that subsequent
requests for the resource always return the same value.
[Caching behavior](#configuration-iscached) can be disabled, if needed.

Since functions are not executed until their corresponding resource is first
requested, the acquisition of these resources is said to be _deferred_.  This
can be beneficial when:

- the initialization of the resource has a performance penalty this is better
incurred when the resource is first needed
- the resource cannot be initialized until some other component has been
prepared first

##### Wrapped Resource Functions

In order to define a resource that returns an actual function, simply wrap the
function in a wrapper function:

<figure><figcaption><em>Example: Resource Function, Wrapped</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {
    getNumber = function(resources, found)
      return function()
        return math.random(100)
      end
    end,
  }})

print(resources.getNumber()) -- 94
print(resources.getNumber()) -- 53
```

##### Resource Function Errors

Errors that occur during the execution of a resource function will be thrown
by Resourceful.

##### Resource Function Signature

Resource functions are invoked with the following signature:

```lua
function (table resources, Instance found) return any
```

###### Parameter: resources

`resources` is the same `table` for acquiring resources that was used to
acquire the function, which allows the function to acquire other resources.

<figure><figcaption><em>Example: Resource Function, Nested</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {
    ceiling = 5,

    getNumber = function(resources, found)
      return function(floor)
        return floor + math.random(resources.ceiling - floor)
      end
    end,
  }})

print(resources.getNumber(2)) -- 4
print(resources.getNumber(2)) -- 2
```

Note that circular references amongst `resources` will cause Resourceful to
throw an error.

<figure><figcaption><em>Example: Resource Function, Circular Reference</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {
    truthy = function(resources, found)
      return not resources.falsey
    end,

    falsey = function(resources, found)
      return not resources.truthy
    end,
  }})

print(resources.truthy()) -- throws an error
```

###### Parameter: found

`found` is the first `Instance` found within the configured
[search path](#configuration-search) that has the same name as the requested
resource, representing the resource that would have been returned if a
resource function by the same name were not defined.

The `found` parameter effectively lets the function choose to conditionally
override that resource when appropriate.

<figure><figcaption><em>Example: Resource Function, Conditional</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = { -- Custom resource loaders
    PlayerLib = function(resources, found)
      -- 50% of the time, return the normal "PlayerLib" script
      -- found by Resourceful.
      if math.random(100) <= 50 then
        return found
      else
        -- Otherwise, ask Resourceful to look for a child
        -- named "TestPlayerLib" within the current library.
        return resources.TestPlayerLib
      end
    end,
  }})

-- Script doesn't know or care if "PlayerLib" is
-- the normal version or test version:
local PlayerLib = resources.PlayerLib
```

###### Return Value

Resource functions can return any data type, whose value will be used as the
value of the acquired resource.  If a resource function returns `nil` and
[strict mode](#configuration-isstrict) is enabled, Resourceful will throw an
error.

##### __init Resource Function

If a special resource function named `__init` is defined, Resourceful will
execute that function when Resourceful is initialized.  `__init` is an
appropriate location to perform common initialization logic that is needed by
any other custom resource, especially for resources whose initialization
should be executed as soon as possible.

<figure><figcaption><em>Example: __init Resource Function</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = { -- Custom resource loaders
    __init = function(resources, found)
      -- Do some expensive initialization logic here that
      -- should occur as soon as possible.
      return {
        GameEngine = script.Parent.initializeGameEngine(),
      }
    end,

    GameEngine = function(resources, found)
      return resources.__init.GameEngine
    end,
  }})
```

`__init` is executed with the
[same function signature](#resource-function-signature) as other resource
functions, although its `found` parameter will always be `nil`.

The return value of `__init` can be acquired and
[cached](#configuration-iscached) like any other resource.

If `__init` is defined but is not a `function`, it will be behave like any
other non-function resource.

### Configuration: isCached

`isCached` is a `boolean` parameter that, when `true`, memorizes the value of
a requested resource when first requested, and returns that value during each
subsequent request.  Defaults to `true`.

<figure><figcaption><em>Example: isCached</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local cached = Resourceful({
  resources = {
    number = function(resources, found)
      return math.random(100)
    end },
  isCached = true })

print(cached.number) -- 17
print(cached.number) -- 17
print(cached.number) -- 17

local not_cached = Resourceful({
  resources = {
    number = function(resources, found)
      return math.random(100)
    end },
  isCached = false })

print(not_cached.number) -- 82
print(not_cached.number) -- 23
print(not_cached.number) -- 76
```

### Configuration: isStrict

`isStrict` is a `boolean` parameter that, when `true`, throws an error if the
requested resource is `nil` or doesn't exist.  Defaults to `true`.

<figure><figcaption><em>Example: isStrict</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local strict = Resourceful({
  resources = { -- Custom resource loaders
    Nil = function(resources, found)
      return nil
    end },
  isStrict = true })

print(strict.Nil) -- throws error
print(strict.missing) -- throws error

local not_strict = Resourceful({
  resources = { -- Custom resource loaders
    Nil = function(resources, found)
      return nil
    end },
  isStrict = false })

print(not_strict.Nil) -- nil
print(not_strict.missing) -- nil
```

Note that even if `isStrict` is set to `false`, Resourceful will throw an
error if a `nil` resource is preceded with the `require` keyword:

<figure><figcaption><em>Example: isStrict With require</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local not_strict = Resourceful({
  isStrict = false })

print(not_strict.require.missing) -- throws an error
```

### Configuration: onError

`onError` is a function with the following signature that is invoked
whenever Resourceful encounters an error.

```lua
function onError(string errMsg, string name) return nil
```

###### Parameter: errMsg

`errMsg` is a `string` description of the error that occurred.

###### Parameter: name

`name` is equivalent to the `string`
["name" configuration](#configuration-name) specified during initialization of
Resourceful, and defaults to `"script"` if `name` was not specified.

###### Return Value

Returns `nil`.

<figure><figcaption><em>Example: onError</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local errorCounter = 0

local function onError(errMsg, name)
  errorCounter = errorCounter + 1
  warn(("Error #%s encountered in '%s': %s")
    :format(errorCounter, name, errMsg))
end

local resources = Resourceful({
  onError = onError,
  isStrict = true })

print(resources.missing) -- Invokes "onError" and then throws error
```

`onError` is invoked before `onErrorEvent` is fired, and before Resourceful
throws its own error.

Errors that occur within `onError` itself are discarded silently.

There is no mechanism for disabling the errors that Resourceful throws.  Calls
to Resourceful can be wrapped in `pcall` or `xpcall` to inhibit Resourceful
errors from halting caller functions.

### Configuration: onErrorEvent

`onErrorEvent` is a `BindableEvent` with the following signature that is
fired whenever Resourceful encounters an error.

```lua
BindableEvent onErrorEvent:Fire(string errMsg, string name)
```

###### Parameter: errMsg

`errMsg` is a `string` description of the error that occurred.

###### Parameter: name

`name` is equivalent to the `string`
["name" configuration](#configuration-name) specified during initialization of
Resourceful, and defaults to `"script"` if `name` was not specified.

<figure><figcaption><em>Example: onErrorEvent</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local onErrorEvent = Instance.new("BindableEvent")
local errorCounter = 0

onErrorEvent.Event:Connect(function (errMsg, name)
  errorCounter = errorCounter + 1
  warn(("Error #%s encountered in '%s': %s")
    :format(errorCounter, name, errMsg))
end)

local resources = Resourceful({
  onErrorEvent = onErrorEvent,
  isStrict = true })

print(resources.missing) -- Fires "onErrorEvent" and then throws error
```

`onErrorEvent` is fired after `onError` is invoked, and before Resourceful
throws its own error.

There is no mechanism for disabling the errors that Resourceful throws.  Calls
to Resourceful can be wrapped in `pcall` or `xpcall` to inhibit Resourceful
errors from halting caller functions.

## Learn More

Read the [Overview](../) to learn how Resourceful can solve
common resource acquisition problems.

Read the [Installation](../installation/) instructions to learn how to make
Resourceful available within your projects.