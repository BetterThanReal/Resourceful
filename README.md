# Resourceful: Overview

Resourceful is a Lua module that allows Roblox developers to use a simple
dot notation syntax to access project resources from within their own scripts.

```lua
local resources = require(script.Parent.Resourceful)

-- Automatically find a resource named "MyHelpers",
-- which is a child Instance within script.Parent:
local MyHelpers = resources.MyHelpers

-- Automatically find and require a ModuleScript named "Main",
-- which is also a child Instance within script.Parent:
local Main = resources.require.Main
```

Resourceful offers the following benefits:

- [Simplified Syntax For Resource Acquisition](https://betterthanreal.github.io/Resourceful/#simplified-syntax-for-resource-acquisition)
- [Customizable Automatic Resource Acquisition](https://betterthanreal.github.io/Resourceful/#customizable-automatic-resource-acquisition)
- [Customizable, On-Demand (Lazy-Loaded) Resource Acquisition](https://betterthanreal.github.io/Resourceful/#customizable-on-demand-lazy-loaded-resource-acquisition)
- [Robust, Developer-Friendly Error Handling For Resource Acquisition](https://betterthanreal.github.io/Resourceful/#robust-developer-friendly-error-handling-for-resource-acquisition)

For more information on how to install and use Resourceful, please read the
[online documentation](https://betterthanreal.github.io/Resourceful/).