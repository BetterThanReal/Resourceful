return function()
  local Resourceful = require(script.parent)

  describe("constructor", function()
    describe("onError", function()
      describe("errors", function()
        it("should error when onError is not a function", function()
          expect(function()
            return Resourceful({
              onError = "wrong",
              search = game,
            })
          end).to.throw("non-function value")
        end)
        it("should error when onErrorEvent is not a BindableEvent", function()
          expect(function()
            return Resourceful({
              onErrorEvent = "wrong",
              search = game,
            })
          end).to.throw("non-BindableEvent value")
        end)
      end)
    end)
    describe("resources", function()
      describe("errors", function()
        it("should error when resources contain failing __init function", function()
          expect(function()
            return Resourceful({
              resources = {
                __init = function() error("custom error") end,
              },
              search = game,
            })
          end).to.throw("custom error")
        end)
        it("should invoke onError function when provided", function()
          local fnErrMsg = nil
          local fnLibraryName = nil

          expect(function()
            return Resourceful({
              name = "MyLib",
              onError = function(errMsg, libraryName)
                fnErrMsg = errMsg
                fnLibraryName = libraryName
              end,
              resources = {
                __init = function() error("custom error") end,
              },
              search = game,
            })
          end).to.throw("custom error")

          expect(string.find(fnErrMsg, "custom error")).never.to.equal(nil)
          expect(fnLibraryName).to.equal("MyLib")
        end)
        it("should invoke onError function safely", function()
          local didError = false

          expect(function()
            return Resourceful({
              name = "MyLib",
              onError = function(errMsg, libraryName)
                didError = true
                error("onError error")
              end,
              resources = {
                __init = function() error("custom error") end,
              },
              search = game,
            })
          end).to.throw("custom error")

          expect(didError).to.equal(true)
        end)
        it("should invoke onErrorEvent when provided", function()
          local onErrorEvent = Instance.new("BindableEvent")
          local eventErrMsg = nil
          local eventLibraryName = nil

          local function onErrorEventFn(errMsg, libraryName)
            eventErrMsg = errMsg
            eventLibraryName = libraryName
          end

          local connection = onErrorEvent.Event:Connect(onErrorEventFn)

          expect(function()
            return Resourceful({
              name = "MyLib",
              onErrorEvent = onErrorEvent,
              resources = {
                __init = function() error("custom error") end,
              },
              search = game,
            })
          end).to.throw("custom error")

          connection:Disconnect()

          expect(string.find(eventErrMsg, "custom error")).never.to.equal(nil)
          expect(eventLibraryName).to.equal("MyLib")
        end)
        it("should invoke onErrorEvent safely", function()
          local onErrorEvent = Instance.new("BindableEvent")
          local eventErrMsg = nil
          local eventLibraryName = nil

          local function onErrorEventFn(errMsg, libraryName)
            eventErrMsg = errMsg
            eventLibraryName = libraryName
            error("onErrorEvent")
          end

          local connection = onErrorEvent.Event:Connect(onErrorEventFn)

          expect(function()
            return Resourceful({
              name = "MyLib",
              onErrorEvent = onErrorEvent,
              resources = {
                __init = function() error("custom error") end,
              },
              search = game,
            })
          end).to.throw("custom error")

          connection:Disconnect()

          expect(string.find(eventErrMsg, "custom error")).never.to.equal(nil)
          expect(eventLibraryName).to.equal("MyLib")
        end)
        it("should invoke onError and onErrorEvent when provided", function()
          local onErrorEvent = Instance.new("BindableEvent")
          local eventErrMsg = nil
          local eventLibraryName = nil
          local fnErrMsg = nil
          local fnLibraryName = nil

          local function onErrorEventFn(errMsg, libraryName)
            eventErrMsg = errMsg
            eventLibraryName = libraryName
          end

          local connection = onErrorEvent.Event:Connect(onErrorEventFn)

          expect(function()
            return Resourceful({
              name = "MyLib",
              onError = function(errMsg, libraryName)
                fnErrMsg = errMsg
                fnLibraryName = libraryName
              end,
              onErrorEvent = onErrorEvent,
              resources = {
                __init = function() error("custom error") end,
              },
              search = game,
            })
          end).to.throw("custom error")

          connection:Disconnect()

          expect(string.find(eventErrMsg, "custom error")).never.to.equal(nil)
          expect(eventLibraryName).to.equal("MyLib")

          expect(string.find(fnErrMsg, "custom error")).never.to.equal(nil)
          expect(fnLibraryName).to.equal("MyLib")
        end)
      end)
    end)
    describe("search target", function()
      describe("errors", function()
        it("should error when search target is non-instance", function()
          expect(function()
            Resourceful({ name = "wrong", search = "wrong" })
          end).to.throw("invalid search target")
        end)
        it("should error when search target is empty table", function()
          expect(function()
            Resourceful({ search = { } })
          end).to.throw("empty search targets")
        end)
        it("should error when search target is table with non-instance", function()
          expect(function()
            Resourceful({ search = { "wrong" } })
          end).to.throw("invalid search target")
        end)
        it("should show library name in error message", function()
          expect(function()
            Resourceful({ name = "MyLibrary", search = 0 })
          end).to.throw("MyLibrary")
        end)
      end)
      describe("success", function()
        it("should succeed when search target is instance", function()
          expect(function()
            Resourceful({ search = game })
          end).never.to.throw()
        end)
        it("should succeed when search target is table with instance", function()
          expect(function()
            Resourceful({ search = { game } })
          end).never.to.throw()
        end)
        it("should succeed when search target is table with multiple instances", function()
          expect(function()
            Resourceful({ search = { game, game.ReplicatedStorage } })
          end).never.to.throw()
        end)
        it("should succeed when search target replaces name", function()
          expect(function()
            Resourceful({ search = game })
          end).never.to.throw()
        end)
      end)
    end)
  end)
  describe("resource acquisition", function()
    describe("errors", function()
      it("should error when resources contain circular dependency", function()
        expect(function()
          return Resourceful({
            resources = {
              prop = function(r) return r.prop end,
            },
            search = game,
          }).prop
        end).to.throw("Circular dependency")
      end)
      it("should error when resources contain failing function", function()
        expect(function()
          return Resourceful({
            resources = {
              prop = function() error("custom error") end,
            },
            search = game,
          }).prop
        end).to.throw("custom error")
      end)
      it("should error when resources contain non-requirable require target", function()
        expect(function()
          return Resourceful({
            resources = {
              prop = false,
            },
            search = game,
          }).require.prop
        end).to.throw("not a ModuleScript")
      end)
    end)
    describe("success", function()
      it("should cache a function result", function()
        local result = "success"
        local count = 0
        local R = Resourceful({
          isCached = true,
          resources = {
            prop = function() count = count + 1; return result end,
          },
          search = game,
        })
        local _ = R.prop, R.prop

        expect(count).to.equal(1)
      end)
      it("should default to caching a function result", function()
        local result = "success"
        local count = 0
        local R = Resourceful({
          resources = {
            prop = function() count = count + 1; return result end,
          },
          search = game,
        })
        local _ = R.prop, R.prop

        expect(count).to.equal(1)
      end)
      it("should not cache a function result when caching is disabled", function()
        local result = "success"
        local count = 0
        local R = Resourceful({
          isCached = false,
          resources = {
            prop = function() count = count + 1; return result end,
          },
          search = game,
        })
        local _ = R.prop, R.prop

        expect(count).to.equal(2)
      end)
      it("should return a function resource", function()
        local fn = function() end
        expect(
          Resourceful({
            resources = {
              prop = function() return fn end,
            },
            search = game,
          }).prop
        ).to.equal(fn)
      end)
      it("should return a function result", function()
        local result = "success"
        expect(
          Resourceful({
            resources = {
              prop = function() return result end,
            },
            search = game,
          }).prop
        ).to.equal(result)
      end)
      it("should return a number resource", function()
        expect(
          Resourceful({
            resources = {
              prop = 5,
            },
            search = game,
          }).prop
        ).to.equal(5)
      end)
      it("should return a property resource referenced by a property function", function()
        local val = 5
        expect(
          Resourceful({
            resources = {
              val = val,
              prop = function(r) return r.val end,
            },
            search = game,
          }).prop
        ).to.equal(val)
      end)
      it("should return a string resource", function()
        expect(
          Resourceful({
            resources = {
              prop = "prop",
            },
            search = game,
          }).prop
        ).to.equal("prop")
      end)
      it("should return a table resource", function()
        local tbl = { key = "value" }
        expect(
          Resourceful({
            resources = {
              prop = tbl,
            },
            search = game,
          }).prop
        ).to.equal(tbl)
      end)
    end)
  end)
  describe("resource require", function()
    describe("errors", function()
      it("should error when missing target is required in non-strict mode", function()
        expect(function()
          return Resourceful({
            isStrict = false,
            resources = {},
            search = game,
          }).require.prop
        end).to.throw("not a ModuleScript")
      end)
      it("should error when missing target is required in strict mode", function()
        expect(function()
          return Resourceful({
            isStrict = true,
            resources = {},
            search = game,
          }).require.prop
        end).to.throw("strict mode")
      end)
      it("should error when non-ModuleScript target is required", function()
        expect(function()
          return Resourceful({
            resources = {
              prop = false,
            },
            search = game,
          }).require.prop
        end).to.throw("not a ModuleScript")
      end)
      it("should error when ModuleScript target with error is required", function()
        expect(function()
          return Resourceful({
            resources = {},
            search = game.ServerScriptService.Tests.Resourceful,
          }).require.error_module
        end).to.throw("error while loading")
      end)
    end)
    describe("success", function()
      it("should succeed when ModuleScript target is required", function()
        expect(
          Resourceful({
            resources = {},
            search = game.ServerScriptService.Tests.Resourceful,
          }).require.success_module
        ).to.equal("success")
      end)
    end)
  end)
  describe("search target acquisition", function()
    describe("success", function()
      it("should return target when target is found in search targets", function()
        expect(
          Resourceful({
            resources = {},
            search = game.ServerScriptService.Tests.Resourceful,
          }).success_module.ClassName
        ).to.equal("ModuleScript")
      end)
      it("should return nil when target is not found in search targets in non-strict mode", function()
        expect(
          Resourceful({
            isStrict = false,
            resources = {},
            search = game,
          }).success_module
        ).to.equal(nil)
      end)
    end)
    describe("success", function()
      it("should error when target is not found in search targets in strict mode", function()
        expect(function()
          return Resourceful({
            isStrict = true,
            resources = {},
            search = game,
          }).success_module
        end).to.throw("strict mode")
      end)
      it("should default to strict mode", function()
        expect(function()
          return Resourceful({
            resources = {},
            search = game,
          }).success_module
        end).to.throw("strict mode")
      end)
    end)
  end)
end