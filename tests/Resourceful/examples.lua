return function(exampleName)
  local Resourceful = require(game.ReplicatedStorage.Scripts.Resourceful)
  local resources = Resourceful({
    name = "SuperCool",

    resources = {
      error_module = function(resources, found)
        return game.ServerScriptService.Tests.Resourceful.error_module
      end,

      ErrorCircular = function(resources, found)
        return resources.Helpers
      end,

      ErrorFunction = function(resources, found)
        error("Function blew up")
      end,

      ErrorInvalidModule = function(resources, found)
        return resources.require.InvalidModule
      end,

      ErrorMissingModule = function(resources, found)
        return resources.require.MissingModule
      end,

      ErrorNilModule = function(resources, found)
        return resources.require.ErrorNil
      end,

      ErrorModule = function(resources, found)
        return resources.require.error_module
      end,

      ErrorNil = function(resources, found)
        return nil
      end,

      ErrorNotFound = function(resources, found)
        return resources.notFound
      end,

      InvalidModule = false,

      StringLib = function(resources, found)
        return resources.Helpers.strings
      end,

      Helpers = function(resources, found)
        warn(("Testing Resourceful resource '%s'"):format(exampleName))
        return resources[exampleName]
      end,
    },
  })
  return resources.StringLib
end