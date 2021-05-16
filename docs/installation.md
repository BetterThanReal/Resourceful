# Resourceful: Installation

## Choosing Where To Install Resourceful

Within a Roblox Studio project, Resourceful can be installed to a single,
shared location where it can be accessed by all project modules that will use
it.  Conversely, it can also be installed as a child within each module that
will use it.

Installing Resourceful to a shared location can ensure that a single, known
version of Resourceful is used across all modules, while also reducing the
file size of the Roblox project.

Installing Resourceful as a child within each module that uses Resourceful may
help simplify the sharing of such modules with other projects, which can be
useful for module libraries.

### Understanding The Resourceful Search Path

When invoking Resourceful with default behavior, Resourceful will
[automatically search for resources](../#automatic-resource-acquisition) in the
parent `Instance` that contains Resourceful.

Thus, if Resourceful is installed to a shared location, invoking that instance
of Resourceful with default behavior will search for resources within that
shared location.

If Resourceful is installed as a child within a module, invoking that instance
of Resourceful with default behavior will search for resources within that
module.

Of course, installing Resourceful to multiple modules would allow each such
module to search itself when acquiring resources.

Each invocation of Resourceful can also be configured with
[custom search paths](../api-reference/#configuration-search) that are as simple
or complex as needed.  This can allow every module within a project to use a
shared instance of Resourceful, while also allowing each module to find the
specific resources it needs.

## Choosing How To Install Resourceful

Resourceful can be installed by loading a Resourceful model file into Roblox
Studio, or by using a developer tool to synchronize Resourceful's source code
into a Roblox Studio project.

### Loading A Resourceful Model File Into Roblox Studio

1. Obtain the latest version of `Resourceful.rbxmx` from the [
GitHub Release Page](https://github.com/BetterThanReal/Resourceful/releases)
2. Insert the model into the chosen parent object(s) within a Roblox Studio
project

### Using A Developer Tool To Synchronize Resourceful

Developers who use tools such as [Rojo](https://rojo.space/) or
[Remodel](https://github.com/rojo-rbx/remodel) can copy the Resourceful source
code to the appropriate location(s):

1. [Download](https://github.com/BetterThanReal/Resourceful/releases) or
[clone](https://github.com/BetterThanReal/Resourceful) the source code for
Resourceful into a local directory
2. Copy or synchronize the `src/Resourceful` folder into a Roblox Studio
project at the appropriate location(s).  Ensure that the new `Instance`
containing Resourceful is named `Resourceful`.

## Invoking Resourceful After Installation

This section contains examples of how to invoke Resourceful after
installation.

### Invoking Resourceful From A Module With Default Behavior

Assuming the following project script hierarchy:

```text
> Lib
  > MyLib
    > MyHelpers
    > Resourceful
    Script
  > ThirdPartyLib
```

`Lib.MyLib.Script` can invoke `Lib.MyLib.Resourceful` to acquire the resource
`Lib.MyLib.MyHelpers`:

<figure><figcaption><em>Lib.MyLib.Script:</em></figcaption></figure>

```lua
local resources = require(script.Parent.Resourceful)

-- Acquire "MyHelpers" in Lib.MyLib.MyHelpers
local MyHelpers = resources.MyHelpers

-- Or, "require" MyHelpers:
MyHelpers = resources.require.MyHelpers
```

Because Resourceful can only search its parent `Lib.MyLib` by default,
Resourceful would not be able to acquire resource `Lib.ThirdPartyLib` with
this configuration.  See the next example for how to specify a custom
configuration that can acquire `Lib.ThirdPartyLib`.

### Invoking Resourceful From A Module With Custom Behavior

Assuming the following project script hierarchy:

```text
> Lib
  > MyLib
    > MyHelpers
    > Resourceful
    Script
  > ThirdPartyLib
```

`Lib.MyLib.Script` can invoke `Lib.MyLib.Resourceful` to acquire resources
`Lib.MyLib.MyHelpers` and `Lib.ThirdPartyLib`:

<figure><figcaption><em>Lib.MyLib.Script:</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Resourceful)
local resources = Resourceful({
  search = { script.Parent, script.Parent.Parent }})

-- Acquire "MyHelpers" in Lib.MyLib.MyHelpers
local MyHelpers = resources.MyHelpers

-- Or, "require" MyHelpers:
MyHelpers = resources.require.MyHelpers

-- Acquire "ThirdPartyLib" in Lib.ThirdPartyLib
local ThirdPartyLib = resources.ThirdPartyLib
```

The
[custom configuration](../api-reference/#instantiating-resourceful-with-custom-configurations)
with
[custom search path](../api-reference/#configuration-search) of
`{ script.Parent, script.Parent.Parent }` allows Resourcesful to find both
`Lib.MyLib.MyHelpers` and `Lib.ThirdPartyLibrary`.

### Invoking Resourceful From A Shared Location With Default Behavior

Assuming the following project script hierarchy:

```text
> Lib
  > MyLib
    > MyHelpers
    Script
  > Resourceful
  > ThirdPartyLib
```

`Lib.MyLib.Script` can invoke `Lib.Resourceful` to acquire the resource
`Lib.ThirdPartyLib`:

<figure><figcaption><em>Lib.MyLib.Script:</em></figcaption></figure>

```lua
local resources = require(script.Parent.Parent.Resourceful)

-- Acquire "ThirdPartyLib" in Lib.ThirdPartyLib
local ThirdPartyLib = resources.ThirdPartyLib
```

Because Resourceful can only search its parent `Lib` by default, Resourceful
would not be able to acquire resource `Lib.MyLib.MyHelpers` with this
configuration.  See the next example for how to specify a custom configuration
that can acquire `Lib.MyLib.MyHelpers`.

### Invoking Resourceful From A Shared Location With Custom Behavior

Assuming the following project script hierarchy:

```text
> Lib
  > MyLib
    > MyHelpers
    Script
  > Resourceful
  > ThirdPartyLib
```

`Lib.MyLib.Script` can invoke `Lib.Resourceful` to acquire resources
`Lib.MyLib.MyHelpers` and `Lib.ThirdPartyLib`:

<figure><figcaption><em>Lib.MyLib.Script:</em></figcaption></figure>

```lua
local Resourceful = require(script.Parent.Parent.Resourceful)
local resources = Resourceful({
  search = { script.Parent, script.Parent.Parent }})

-- Acquire "MyHelpers" in Lib.MyLib.MyHelpers
local MyHelpers = resources.MyHelpers

-- Or, "require" MyHelpers:
MyHelpers = resources.require.MyHelpers

-- Acquire "ThirdPartyLib" in Lib.ThirdPartyLib
local ThirdPartyLib = resources.ThirdPartyLib
```

The
[custom configuration](../api-reference/#instantiating-resourceful-with-custom-configurations)
with
[custom search path](../api-reference/#configuration-search) of
`{ script.Parent, script.Parent.Parent }` allows Resourcesful to find both
`Lib.MyLib.MyHelpers` and `Lib.ThirdPartyLibrary`.

## More Examples

Please refer to the [API Reference](../api-reference/) for examples of how to use
each configuration option supported by Resourceful, including
[custom resource acquisition logic](../api-reference/#configuration-resources).

## Learn More

Read the [Overview](../) to learn how Resourceful can solve
common resource acquisition problems.

Read the [API Reference](../api-reference/) to learn more about advanced usage
of Resourceful.