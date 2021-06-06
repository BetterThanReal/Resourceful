# Resourceful: API Reference

## Loading The Module

Invoking `require()` upon the `Resourceful` module will return a `Resourceful`
instance configured with default behavior, which can be used to acquire
project resources using a clean syntax with robust error handling. 

### Acquiring Resources 

Acquiring resources is as simple as instantiating Resourceful, and specifying
the name of the resource to be acquired:

```lua
local resources = require(script.Parent.Resourceful)
local MyHelpers = resources.MyHelpers -- Find resource "MyHelpers"
```

#### Requiring Resources

Prepending the resource name with `require` causes Resourceful to issue
`require()` upon the resource, which is expected to be a `ModuleScript`:

```lua
local resources = require(script.Parent.Resourceful)
local Main = resources.require.Main
-- Equivalent to: local Main = require(resources.Main)
-- but offers additional error-handling!
```

If an error occurs when invoking `require()`, or if the specified resource is
not a `ModuleScript`, Resourceful will wrap and throw the error with
Resourceful's own error message.

#### Automatic Resource Acquisition

By default, Resourceful offers automatic resource acquisition to search for
requested resources within the immediate children of Resourceful's
`script.Parent`:

```lua
local resources = require(script.Parent.Resourceful)

-- Automatically find a resource named "MyHelpers",
-- which is a child Instance within script.Parent:
local MyHelpers = resources.MyHelpers

-- Automatically find and require a ModuleScript named "Main",
-- which is also a child Instance within script.Parent:
local Main = resources.require.Main
```

[`Resourceful()`][function-resourceful] can be invoked to create a
`Resourceful` instance with customized behavior.

## Class Methods

<table>
<thead>
<tr><th>Function Name</th><th>Description</th></tr>
</thead>
<tbody>
<tr><td><a href='#function-resourceful'>Resourceful()</a></td>
<td>Creates and returns a <code>Resourceful</code> instance with customized
behavior, if a custom configuration is specified, or default behavior, if
none is specified.</td></tr>
</tbody></table>

### Function: Resourceful()

`Resourceful()` can be invoked to create a `Resourceful` instance with
customized behavior ([example][examples]), which can:

- allow multiple `Instance` objects to be [searched][config-property-search] when looking for resources
- define [custom resources][config-property-resources], including [resource functions][resource-functions] to acquire resources on-demand
- enable or disable [caching of resources][config-property-iscached]
- cause [missing resources to return nil][config-property-isstrict] instead of throwing an error

##### Signature

```lua
Resourceful Resourceful([table config])
```

##### Parameters

<table>
<thead>
<tr class='header'>
  <th>Name</th><th>Type</th><th>Synopsis</th></tr>
</thead>
<tbody>
<tr><td>config</td><td><code>table</code> (optional)</td>
<td>Contains <a href="#config-properties">configuration properties</a> to
define the behavior of the <code>Resourceful</code> object to be created and
returned.  If not specified, a <code>Resourceful</code> object with default
behavior will be returned.</td></tr>
</tbody>
</table>

##### Returns

<table>
<thead>
<tr class='header'>
  <th>Type(s)</th><th>Synopsis</th></tr>
</thead>
<tbody>
<tr><td>Resourceful</td>
<td>The <code>Resourceful</code> object configured according to the specified
<code>config</code>, or with default behavior if <code>config</code> was not
specified.</td></tr>
</tbody>
</table>

##### Side-Effects

`Resourceful()` will execute the resource function
[`config.resources.__init`][__init-resource-function], if it has been
defined.

##### Errors

`Resourceful()` will throw an error if `config` is present but is not a
`table`.

`Resourceful()` will throw an error if `config` contains a known property with
an invalid value.

Errors that occur during the execution of optional resource function
[__init][__init-resource-function] will be wrapped and thrown by Resourceful.

##### Caveats

None.

##### Examples

<figure><figcaption><em>Example: Customized Behavior</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local configOptions = {
  -- Custom configuration options go here
  -- (details omitted for brevity)
}

-- Create an instance of Resourceful with customized behavior:
local resources = Resourceful(configOptions)

local otherConfigOptions = {
  -- An example of another custom configuration
  -- (details omitted for brevity)
}

-- Multiple instances of Resourceful, each with customized behavior, can be
-- used simultaneously.
local otherResources = Resourceful(otherConfigOptions)

-- Using the customized Resourceful instance:
local MyHelperLib = resources.require.MyHelperLib

-- Using the other customized Resourceful instance:
local ThirdPartyLib = otherResources.require.ThirdPartyLib
```

#### config Properties

<table>
<thead>
<tr class='header'>
  <th>Name</th><th>Type</th><th>Synopsis</th></tr>
</thead>
<tbody>
<tr><td>isCached</td><td><code>boolean</code> (optional)</td>
<td><p>When <code>true</code>, causes Resourceful to memorize the value of
requested resources when they are first requested, returning those values
during subsequent requests.  Defaults to <code>true</code>.
(<a href="#config-property-iscached">More details</a>)</p></td></tr>
<tr><td>isStrict</td><td><code>boolean</code> (optional)</td>
<td><p>When <code>true</code>, causes Resourceful to throw an error when a
requested resource is <code>nil</code> or doesn't exist.  Defaults to
<code>true</code>.
(<a href="#config-property-isstrict">More details</a>)</p></td></tr>
<tr><td>name</td><td><code>string</code> (optional)</td>
<td><p>When specified, is reported in error messages thrown by Resourceful.
Defaults to <code>nil</code>.
(<a href="#config-property-name">More details</a>)</p></td></tr>
<tr><td>resources</td><td><code>table</code> (optional)</td>
<td><p>Contains zero or more resource definitions, of any type of data, to be
made available for resource acquisition.  Defaults to <code>{}</code>.
(<a href="#config-property-resources">More details</a>)</p></td></tr>
<tr><td>search</td><td><code>Instance</code>, or <code>table</code> of
<code>Instance</code> objects (optional)</td>
<td><p>An <code>Instance</code> object, or <code>table</code> of zero or
more <code>Instance</code> objects, to be searched when automatically
acquiring resources.  Defaults to the <code>Parent</code> of the Resourceful
<code>Instance</code>.
(<a href="#config-property-search">More details</a>)</p></td></tr>
</tbody>
</table>

##### config Property: isCached

`isCached` is an optional `boolean` parameter that, when `true`, causes
Resourceful to memorize the value of requested resources when they are first
requested, returning those values during subsequent requests.  Defaults to
`true`.

Memorized values can improve performance for
[resource functions][resource-functions] that take time to execute.  For
`Instance` resources found during
[automatic resource acquisition][automatic-resource-acquisition], memorized
values prevent the need for traversing through the
[search path][config-property-search] again.

###### Errors

`Resourceful()` will throw an error if `config.isCached` is present but is not
a `boolean`.

###### Examples

<figure><figcaption><em>Example: isCached</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local cached = Resourceful({
  isCached = true,
  resources = {
    number = function(resources, found)
      return math.random(100)
    end }})

print(cached.number) -- 17
print(cached.number) -- 17
print(cached.number) -- 17

local not_cached = Resourceful({
  isCached = false,
  resources = {
    number = function(resources, found)
      return math.random(100)
    end }})

print(not_cached.number) -- 82
print(not_cached.number) -- 23
print(not_cached.number) -- 76
```

##### config Property: isStrict

`isStrict` is an optional `boolean` parameter that, when `true`, causes
Resourceful to thrown an error when a requested resource is `nil` or doesn't
exist.  Defaults to `true`.

###### Errors

`Resourceful()` will throw an error if `config.isStrict` is present but is not
a `boolean`.

###### Examples

<figure><figcaption><em>Example: isStrict</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local strict = Resourceful({
  isStrict = true,
  resources = {
    Nil = function(resources, found)
      return nil
    end }})

print(strict.Nil) -- throws error
print(strict.missing) -- throws error

local not_strict = Resourceful({
  isStrict = false,
  resources = {
    Nil = function(resources, found)
      return nil
    end }})

print(not_strict.Nil) -- nil
print(not_strict.missing) -- nil
```

Note that even if `isStrict` is set to `false`, Resourceful will throw an
error if a `nil` resource is preceded with the
[`require`][requiring-resources]:

<figure><figcaption><em>Example: isStrict With require</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)

local not_strict = Resourceful({
  isStrict = false })

print(not_strict.require.missing) -- throws an error
```

##### config Property: name

`name` is an optional `string` parameter that, when specified, is reported in
error messages thrown by Resourceful.  Defaults to `nil`.

When writing libraries to be shared with others, specifying a `name` can help
users of your libraries to more easily identify and troubleshoot resource
issues within your libraries.

###### Errors

`Resourceful()` will throw an error if `config.name` is present but is not a
`string`.

###### Examples

<figure><figcaption><em>Example: name</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({ name = "MyLib" })
```

##### config Property: resources

`resources` is an optional `table` parameter of zero or more resource
definitions, of any type of data, to be made available for resource
acquisition.  Defaults to `{}`.

The name of each element within `resources` defines the name of a custom
resource that can be acquired.  An element's corresponding value defines the
value of that resource.

Resources that are assigned a data type other than `function` are returned
immediately by Resourceful whenever those resources are requested.  In this
case, Resourceful will not search for similarly named `Instance` children
located within the defined [search path][config-property-search], thus
bypassing [automatic resource acquisition][automatic-resource-acquisition].

For resources that are defined as functions, including the special resource
named [`__init`][__init-resource-function], please refer to
[Resource Functions][resource-functions].

###### Errors

`Resourceful()` will throw an error if `config.resources` is present but is
not a `table`.

Errors that occur during the execution of optional resource function
[__init][__init-resource-function] will be wrapped and thrown by Resourceful.

###### Examples

<figure><figcaption><em>Example: resources</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {
    boolResource = true,
    numResource = 3.14,
    strResource = "hello",
    tableResource = { value = true },

    strResourceFn = function(resources, found)
      return "Hello!"
    end,

    functionResource = function(resources, found)
      return function(name) return ("Hi, %s!"):format(name) end
    end,

    __init = function(resources, found)
      print("Initializing resources!")
    end,
  }})

-- "Initializing resources!" will be printed here,
-- because the above invocation of Resourceful()
-- will execute resource function __init.

print(resources.boolResource) -- true
print(resources.numResource) -- 3.14
print(resources.strResource) -- "hello"
print(resources.tableResource.value) -- true
print(resources.strResourceFn) -- "Hello!"
print(resources.functionResource("person")) -- "Hi, person!"
```

##### config Property: search

`search` is an optional `Instance`, or `table` of `Instance` objects, to be
searched when automatically acquiring resources.  Note that specifying an
empty table effectively disables Resourceful's
[automatic resource acquisition][automatic-resource-acquisition].  Defaults
to the `Parent` of the Resourceful `Instance`.

If multiple `Instance` objects are specified, they are searched in the order
in which they are specified, until the first `Instance` is found with an
immediate child whose name matches the requested resource.

If a [custom resource][config-property-resources] of the same name is
defined, and the resource is not a [resource function][resource-functions],
that resource will be used, bypassing automatic resource acquisition.
However, if the resource _is_ a resource function, automatic resource
acquisition _will_ be performed, with the acquired resource being passed to
the resource function as a [function parameter][resource-function-signature].
The function can thus decide whether to return that `Instance`, or some other
value, as the definition of the resource.

Searching is performed by executing `:FindFirstChild(resourceName, false)` on
each search target, where `resourceName` is the `string` name of the resource
to be found, and `false` instructs Roblox to search only the immediate
children of the search targets, and not deeper descendants.

###### Errors

`Resourceful()` will throw an error if `config.search` is present but has a
type other than `Instance`, empty `table`, or `table` of `Instance` objects.

###### Examples

<figure><figcaption><em>Example: search</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  search = {
    script.Parent,
    script.Parent.Parent,
    game:GetService("ReplicatedStorage"):FindFirstChild("Scripts", false),
  }})

-- Resourceful searches for the following "Helpers" instances:
-- script.Parent.Helpers
-- script.Parent.Parent.Helpers
-- game:GetService("ReplicatedStorage").Scripts.Helpers
local Helpers = resources.Helpers
```

#### Resource Functions

If a [custom resource][config-property-resources] is defined as a `function`,
the function will be executed to define the actual value of the resource:

<figure><figcaption><em>Example: Resource Function</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {
    greeting = function(resources, found)
      return "Hello!"
    end,
  }})

print(resources.greeting) -- Hello!
```

Since functions are not executed until their corresponding resources are first
requested, the acquisition of these resources is said to be _deferred_, or
_lazy-loaded_.  This can be beneficial when:

- the initialization of the resource has a performance penalty this is better
incurred when the resource is first needed
- the resource cannot be initialized until some other component has been
prepared first

If [caching][config-property-iscached] is enabled, the results of the
`function` execution will be memorized, and returned for all future requests
of that resource:

<figure><figcaption><em>Example: Resource Function Caching</em></figcaption></figure>

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

With caching disabled, the function is executed each time its corresponding
resource is requested:

<figure><figcaption><em>Example: Resource Function Without Caching</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  isCached = false,
  resources = {
    number = function(resources, found)
      return math.random(100)
    end,
  }})

print(resources.number) -- 41
print(resources.number) -- 87
```

##### Signature

Resource functions are invoked with the following signature:

```lua
function (table resources, Instance found) return Variant
```

##### Parameters

<table>
<thead>
<tr class='header'>
  <th>Name</th><th>Type</th><th>Synopsis</th></tr>
</thead>
<tbody>
<tr><td>resources</td><td><code>table</code></td>
<td>The same <code>table</code> for acquiring resources that was returned from
<a href="#function-resourceful"><code>Resourceful()</code></a>, which allows
the function to acquire other resources.
(<a href="#parameter-resources">More details</a>).
</td></tr>
<tr><td>found</td><td><code>Instance</code>&nbsp;</td>
<td>The first <code>Instance</code> found within the configured
<a href="#config-property-search">search path</a> that has the same name as
the requested resource, representing the resource that would have been
returned if a resource function by the same name were not defined.
(<a href="#parameter-found">More details</a>).
</td></tr>
</tbody>
</table>

##### Returns

<table>
<thead>
<tr class='header'>
  <th>Type(s)</th><th>Synopsis</th></tr>
</thead>
<tbody>
<tr><td>Variant (optional)</td>
<td>Resource functions can return any data type, whose value will be used
as the value of the acquired resource.</td></tr>
</tbody>
</table>

##### Side-Effects

Resource functions perform whatever side-effects they were programmed to
perform.

##### Errors

Resource functions will throw whatever errors they were programmed to throw.
Any such errors will be wrapped and thrown by Resourceful.

If a resource function returns `nil` and
[strict mode][config-property-isstrict] is enabled, Resourceful will throw an
error.

Circular references amongst `resources` will cause Resourceful to throw an
error.

##### Caveats

None.

###### Parameter: resources

`resources` is the same `table` for acquiring resources that was returned from
[Resourceful()][function-resourceful], which allows the function to acquire
other resources.

<figure><figcaption><em>Example: Resource Chaining</em></figcaption></figure>

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
[search path][config-property-search] that has the same name as the requested
resource, representing the resource that would have been returned if a
resource function by the same name were not defined.

The `found` parameter effectively lets the function choose to conditionally
override that resource when appropriate.

<figure><figcaption><em>Example: Resource Function, Conditional</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {

    PlayerLib = function(resources, found)
      -- When "resources.PlayerLib" is requested, for 90% of players it should
      -- return the normal "PlayerLib" Instance child of the script parent:
      if math.random(100) <= 90 then
        return found
      else
        -- For the remaining players, "resources.PlayerLib" should instead
        -- return the "TestPlayerLib" Instance child of the script parent:
        return resources.TestPlayerLib
      end
    end,
  }})

-- For 10% of players, PlayerLib actually will be "TestPlayerLib":
local PlayerLib = resources.require.PlayerLib
```

##### __init Resource Function

If a special resource function named `__init` is defined, Resourceful will
execute that function when
[`Resourceful()`][function-resourceful] is invoked.  `__init` is an
appropriate location to perform common initialization logic that is needed by
other [custom resources][config-property-resources], especially those whose
initialization should be executed as soon as possible.

<figure><figcaption><em>Example: __init Resource Function</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = {

    __init = function(resources, found)
      return {
        -- Do some expensive initialization logic here,
        -- just once, as soon as Resourceful() is invoked.
        InitializedGameEngine = resources.GameEngine.initialize(),
      }
    end,

    isClient = game:GetService("RunService").isClient(),

    GameEngine = function(resources, found)
      -- Load the client or server version of the game engine:
      if resources.isClient then
        return resources.require.ClientGameEngine
      else
        return resources.require.ServerGameEngine
      end
    end,

    InitializedGameEngine = function(resources, found)
      -- Return the game engine that was initialized
      -- when Resourceful() was invoked.
      return resources.__init.InitializedGameEngine
    end,
  }})

-- Acquire the resource named "InitializedGameEngine":
local engine = resources.InitializedGameEngine
```

`__init` is executed with the
[same function signature][resource-function-signature] as other resource
functions, although its `found` parameter will always be `nil`.

The return value of `__init` can be [acquired][acquiring-resources] and
[cached][config-property-iscached] like any other resource.

If `__init` is defined but is not a `function`, it will be behave like any
other non-function [custom resource][config-property-resources].

## Learn More

Read the [Overview][] to learn how Resourceful can solve
common resource acquisition problems.

Read the [Installation][] instructions to learn how to make
Resourceful available within your projects.

[__init-resource-function]: #__init-resource-function
  "__init Resource Function"

[acquiring-resources]: #acquiring-resources "Acquiring Resources"

[automatic-resource-acquisition]: #automatic-resource-acquisition
  "Automatic Resource Acquisition"

[config-property-iscached]: #config-property-iscached
  "config Property: isCached"

[config-property-isstrict]: #config-property-isstrict
  "config Property: isStrict"

[config-property-resources]: #config-property-resources
  "config Property: resources"

[config-property-search]: #config-property-search "config Property: search"

[examples]: #examples "Function: Resourceful(): Examples"

[function-resourceful]: #function-resourceful "Function: Resourceful()"

[requiring-resources]: #requiring-resources "Requiring Resources"

[resource-function-signature]: #signature_1 "Resource Function Signature"

[resource-functions]: #resource-functions "Resource Functions"

[Installation]: ./installation.md "Installation"

[Overview]: ./index.md "Overview"