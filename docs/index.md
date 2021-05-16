# Resourceful: Overview

Resourceful is a Lua module that allows Roblox developers to easily import
scripts and resources into their own scripts, centralizing resource
acquisition logic with a simple `require` statement.

```lua
local resources = require(script.Parent.Resourceful)
-- Acquire a resource named "HelperLib":
local HelperLib = resources.HelperLib
-- Require a resource named "MyLib":
local MyLib = resources.require.MyLib
```

Resourceful offers the following benefits:

- [Simplified Syntax For Resource Acquisition](#simplified-syntax-for-resource-acquisition)  
- [Automatic Resource Acquisition](#automatic-resource-acquisition)  
- [On-Demand (Deferred) Custom Resource Acquisition](#on-demand-deferred-custom-resource-acquisition)  
- [Centralized, Custom Logic For Resource Acquisition](#centralized-custom-logic-for-resource-acquisition)  
- [Robust Error Handling For Resource Acquisition](#robust-error-handling-for-resource-acquisition)  
- [Developer-Friendly Error Messages](#developer-friendly-error-messages)  
- [Portable Logic For Resource Acquisition In Libraries](#portable-logic-for-resource-acquisition-in-libraries)

## Benefits

### Simplified Syntax For Resource Acquisition

Resourceful allows developers to have a cleaner syntax for their resource
acquisition logic:

```lua
local resources = require(script.Parent.Resourceful)
-- Acquire a resource named "HelperLib":
local HelperLib = resources.HelperLib
-- Require a resource named "MyLib":
local MyLib = resources.require.MyLib
```

This syntax is an improvement from the repetitive `require()`,
`:FindFirstChild`, and `:WaitForChild` statements that often appear at the
beginning of each Roblox script:

```lua
local HelperLib = script.Parent:FindFirstChild("HelperLib", false)
local MyLib = require(script.Parent:FindFirstChild("MyLib", false))
```

### Automatic Resource Acquisition

By default, Resourceful looks for resources in the immediate children of
Resourceful's parent.  Thus, if your project script hierarchy is structured
like this:

```text
> Lib
  > MyLib
    > MyHelpers
    > Resourceful
    Script
  > ThirdPartyLib
```

Resourceful would look for resources in the immediate children of `MyLib`.
Note that the list of
[instances searched by Resourceful](./api-reference/#configuration-search) can be
specified by the developer during invocation of Resourceful, and usually
includes `script.Parent` and `script.Parent.Parent`:

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  search = { script.Parent, script.Parent.Parent }})

-- Finds "MyHelpers" in script.Parent.MyHelpers
local MyHelpers = resources.MyHelpers

-- Finds "ThirdPartyLib" in script.Parent.Parent.ThirdPartyLib
local ThirdPartyLib = resources.ThirdPartyLib
```

In the preceding example, Resourceful would look for resources in `MyLib` and
`Lib`, in that order.

### On-Demand (Deferred) Custom Resource Acquisition

Beyond [automatic resource acquisition](#automatic-resource-acquisition),
Resourceful can be configured to support
[custom resources](./api-reference/#configuration-resources) of any data type,
including functions that return a resource when requested.  Since the results
of resource acquisition are cached by default, Resourceful only incurs the
performance penalty of acquiring a resource at the moment it is first
requested.

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  resources = { -- Custom resource loaders
    GameEngine = function(resources, found)
      -- Do some expensive initialization logic here, just once.
      return script.Parent.initializeGameEngine()
    end,
  }})

-- Acquire the resource named "GameEngine":
local GameEngine = resources.GameEngine
```

[Caching behavior](./api-reference/#configuration-iscached) can be controlled by
invoking Resourceful with a
[custom configuration](./api-reference/#instantiating-resourceful-with-custom-configurations).

### Centralized, Custom Logic For Resource Acquisition

Resourceful allows developers to centralize their
[custom resource acquisition logic](./api-reference/#configuration-resources),
removing the need for duplication of custom logic across multiple scripts.
For example, if your project contains several scripts that each need to
conditionally load a resource in the same manner, you can define a shared
`ModuleScript` (usually named `resources.lua`) to invoke Resourceful with
custom logic for conditional resource acquisition.

In the following example, `Resourceful` is configured to load either a normal
player library, or test version of a player library, based on a random number:

<figure><figcaption><em>Example: resources.lua</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
return Resourceful({
  resources = { -- Custom resource loaders
    PlayerLib = function(resources, found)
      -- 50% of the time, return the normal "PlayerLib" script
      -- found by Resourceful.
      if math.random(100) <= 50 then
        return found
      else
        -- Otherwise, ask Resourceful to look for a child
        -- named "TestPlayerLib" within the current module.
        return resources.TestPlayerLib
      end
    end,
  }})
```

If multiple scripts need to acquire the same `PlayerLib` object, not
caring (nor wanting) to know how `PlayerLib` was instantiated, those scripts
can all use the same simple syntax to import the resource:

<figure><figcaption><em>Example: Calling Script</em></figcaption></figure>

```lua
local resources = require(script.Parent.resources)

-- Script doesn't know or care if "PlayerLib" is
-- the normal version or test version:
local PlayerLib = resources.PlayerLib
```

By default, acquired
[resources are cached](./api-reference/#configuration-iscached) so that subsequent
acquisitions return the same resource.  This behavior, as well as the behavior
for when
[errors are encountered](./api-reference/#configuration-onerror) or
[resources are not found](./api-reference/#configuration-isstrict), can be
[customized](./api-reference/#instantiating-resourceful-with-custom-configurations)
by the developer.

### Robust Error Handling For Resource Acquisition

Resourceful implements error handling around all of its critical operations,
ensuring that Resourceful isn't left in an unusable state after errors occur.

### Developer-Friendly Error Messages

Resourceful ensures that errors related to resource acquisition are reported
to the developer in a clear and concise manner via the output console of
Roblox Studio.  Additional [error handlers](./api-reference/#configuration-onerror)
can be specified by the developer too.

Instead of receiving cryptic error messages such as:

```text
ReplicatedStorage.Scripts.Lib.SuperCool:42:
invalid argument #1 to 'concat' (table expected, got nil)
```

Resourceful provides meaningful error messages:

```text
ReplicatedStorage.Scripts.Lib.SuperCool:42:
SuperCool was unable to load required module WorkHorse.
Please consult the installation instructions for SuperCool.
ERROR: Module code did not return exactly one value
```

These error messages are especially helpful for developers who use libraries
authored by others.  If you intend to write a library to be shared with
others, consider using Resourceful to help your users identify resource
acquisition issues more easily.

### Portable Logic For Resource Acquisition In Libraries

When Resourceful was authored, no package manager was available for Roblox
developers to use when writing their own games or libraries.  Developers who
wrote libraries had to decide how other developers would obtain and install
their libraries, as well as additional "third-party" dependencies that were
required.  Because several libraries often included the same third-party
dependencies, multiple copies of those dependencies would appear within a
developer's project.

Resourceful allows libraries to more gracefully handle scenarios where a
developer relocates third-party dependencies into a shared location like
`ReplicatedStorage.Scripts`.

## Learn More

Read the [Installation](./installation/) instructions to learn how to make
Resourceful available within your projects.

Read the [API Reference](./api-reference/) to learn more about advanced usage
of Resourceful.