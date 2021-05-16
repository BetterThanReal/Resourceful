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

- [Simplified Syntax For Resource Acquisition](https://betterthanreal.github.io/Resourceful/#simplified-syntax-for-resource-acquisition)  
- [Automatic Resource Acquisition](https://betterthanreal.github.io/Resourceful/#automatic-resource-acquisition)  
- [On-Demand (Deferred) Custom Resource Acquisition](https://betterthanreal.github.io/Resourceful/#on-demand-deferred-custom-resource-acquisition)  
- [Centralized, Custom Logic For Resource Acquisition](https://betterthanreal.github.io/Resourceful/#centralized-custom-logic-for-resource-acquisition)  
- [Robust Error Handling For Resource Acquisition](https://betterthanreal.github.io/Resourceful/#robust-error-handling-for-resource-acquisition)  
- [Developer-Friendly Error Messages](https://betterthanreal.github.io/Resourceful/#developer-friendly-error-messages)  
- [Portable Logic For Resource Acquisition In Libraries](https://betterthanreal.github.io/Resourceful/#portable-logic-for-resource-acquisition-in-libraries)

For more information on how to install and use Resourceful, please read the
[online documentation](https://betterthanreal.github.io/Resourceful/).