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
[automatically search for resources][automatic-resource-acquisition]
in the parent `Instance` that contains Resourceful.

Thus, if Resourceful is installed to a shared location, invoking that instance
of Resourceful with default behavior will search for resources within that
shared location.

If Resourceful is installed as a child within a module, invoking that instance
of Resourceful with default behavior will search for resources within that
module.

Installing Resourceful to multiple modules would allow each such module to
search itself when acquiring resources.

Each invocation of Resourceful can also be configured with
[custom search paths][config-property-search] that are as simple or complex
as needed.  This can allow every module within a project to use a shared
instance of Resourceful, while also allowing each module to find the specific
resources it needs.

## Choosing How To Install Resourceful

Resourceful can be installed by loading a Resourceful model file into Roblox
Studio, or by using a developer tool to synchronize Resourceful's source code
into a Roblox Studio project.

### Loading A Resourceful Model File Into Roblox Studio

1. Obtain the latest version of `Resourceful.rbxmx` from the
[GitHub Release Page][]
2. Insert the model into the chosen parent object(s) within a Roblox Studio
project

### Using A Developer Tool To Synchronize Resourceful

Developers who use tools such as [Rojo](https://rojo.space/) or
[Remodel](https://github.com/rojo-rbx/remodel) can copy the Resourceful source
code to the appropriate location(s):

1. [Download][GitHub Release Page] or
[clone](https://github.com/BetterThanReal/Resourceful) the source code for
Resourceful into a local directory
2. Copy or synchronize the `src/Resourceful` folder into a Roblox Studio
project at the appropriate location(s).  Ensure that the new `Instance`
containing Resourceful is named `Resourceful`.

## Learn More

Read the [Overview][] to learn how Resourceful can solve common resource
acquisition problems.

Read the [API Reference][] to learn more about getting started with
Resourceful, and how to customize its behavior.

[automatic-resource-acquisition]: ./api-reference.md#automatic-resource-acquisition
  "API Reference: Automatic Resource Acquisition"

[config-property-search]: ./api-reference.md#config-property-search
  "API Reference: config Property: search"

[GitHub Release Page]: https://github.com/BetterThanReal/Resourceful/releases
  "GitHub: Resourceful Releases"

[API Reference]: ./api-reference.md "API Reference"

[Overview]: ./index.md "Overview"