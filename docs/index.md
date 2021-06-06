# Resourceful: Overview

### Simplified Syntax For Resource Acquisition

Resourceful is a Lua module that allows Roblox developers to use a simple
dot notation syntax to access project resources from within their own scripts.

```lua
local resources = require(script.Parent.Resourceful)

-- Find a resource named "MyHelpers":
local MyHelpers = resources.MyHelpers

-- Find and require a ModuleScript named "Main":
local Main = resources.require.Main
```

### Customizable, Automatic Resource Acquisition

By default, Resourceful offers
[automatic resource acquisition][automatic-resource-acquisition] to search
for requested resources within the immediate children of Resourceful's
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

By invoking Resourceful with a [custom configuration][function-resourceful],
the list of Roblox project paths that are searched during automatic resource
acquisition can be specified.  For example, to specify a
[search path][config-property-search] consisting of `script.Parent` and
`script.Parent.Parent`:

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  search = {
    script.Parent,
    script.Parent.Parent
  }})

  --[[ Assuming the following project hierarchy:
    > Lib
      > Lib.MyLib
        > Lib.MyLib.Main
        > Lib.MyLib.MyHelpers
        > Lib.MyLib.Resourceful
        > Lib.MyLib.Script (this script)
      > Lib.ThirdPartyLib
  ]]--

-- Finds "MyHelpers" in Lib.MyLib (script.Parent)
local MyHelpers = resources.MyHelpers

-- Finds "Main" in Lib.MyLib (script.Parent), and requires it
local Main = resources.require.Main

-- Finds "MyLib" in Lib (script.Parent.Parent), and requires it
local MyLib = resources.require.MyLib

-- Finds "ThirdPartyLib" in Lib (script.Parent.Parent)
local ThirdPartyLib = resources.ThirdPartyLib
```

### Customizable, On-Demand (Lazy-Loaded) Resource Acquisition

Resourceful can be [customized][function-resourceful] to also support the
definition and creation of custom project
[resources][config-property-resources], as simple or as complex as needed:

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = { -- Custom resource loaders

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

Resourceful can be configured to support custom resources of any data type,
including [resource functions][resource-functions] that return a resource.
Such functions are not executed until requested, allowing on-demand, deferred,
lazy-loading of resources that are cached by default for better performance:

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = { -- Custom resource loaders

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
      -- Do some expensive initialization logic here, just once.
      return resources.GameEngine.initialize()
    end,
  }})

-- Acquire the resource named "InitializedGameEngine":
local engine = resources.InitializedGameEngine

-- By default, resources are cached, and won't be initialized twice:
print(engine == resources.InitializedGameEngine) -- true
```

[Caching behavior][config-property-iscached] can be controlled by invoking
Resourceful with a custom configuration.

### Robust, Developer-Friendly Error Handling For Resource Acquisition

Resourceful implements error handling around all of its critical operations,
ensuring that Resourceful isn't left in an unusable state after errors occur.

Resourceful errors are reported to the developer in a clear and concise manner
via the output console of Roblox Studio.

Instead of receiving cryptic error messages such as:

```text
ReplicatedStorage.Scripts.Lib.SuperCool:42:
invalid argument #1 to 'concat' (table expected, got nil)
```

Resourceful provides meaningful error messages:

```text
ReplicatedStorage.Scripts.Lib.SuperCool:42:
Resourceful resource 'TableHelper' was neither found nor defined for SuperCool
while resolving 'StringLib', 'Helpers', 'TableHelper', and strict mode is
enabled  
```

These error messages are especially helpful for developers who use libraries
authored by others.  If you intend to write a library to be shared with
others, consider using Resourceful to help your users identify resource
acquisition issues more easily.

## Summary of Benefits

Resourceful offers the following benefits:

- [Simplified Syntax For Resource Acquisition](#simplified-syntax-for-resource-acquisition)
- [Customizable Automatic Resource Acquisition](#customizable-automatic-resource-acquisition)
- [Customizable, On-Demand (Lazy-Loaded) Resource Acquisition](#customizable-on-demand-lazy-loaded-resource-acquisition)
- [Robust, Developer-Friendly Error Handling For Resource Acquisition](#robust-developer-friendly-error-handling-for-resource-acquisition)

## Learn More

Read the [Installation][] instructions to learn how to make Resourceful
available within your projects.

Read the [API Reference][] to learn more about getting started with
Resourceful, and how to customize its behavior.

[automatic-resource-acquisition]: ./api-reference.md#automatic-resource-acquisition
  "API Reference: Automatic Resource Acquisition"

[config-property-iscached]: ./api-reference.md#config-property-iscached
  "API Reference: config Property: isCached"

[config-property-resources]: ./api-reference.md#config-property-resources
  "API Reference: config Property: resources"

[config-property-search]: ./api-reference.md#config-property-search
  "API Reference: config Property: search"

[function-resourceful]: ./api-reference.md#function-resourceful
  "API Reference: Function: Resourceful()"

[resource-functions]: ./api-reference.md#resource-functions
  "API Reference: Resource Functions"

[API Reference]: ./api-reference.md "API Reference"

[Installation]: ./installation.md "Installation"