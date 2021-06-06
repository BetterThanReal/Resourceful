return function()
  local Resourceful = require(script.parent)

  describe("Resourceful()", function()
    describe("config", function()
      describe("errors", function()
        it("should error when args[1] ~= table or nil", function()
          expect(function()
            Resourceful(false)
          end).to.throw("Invalid value for argument")
        end)
        it("should error when 'isCached' property of args[1] ~= boolean or nil", function()
          expect(function()
            Resourceful({ isCached = "wrong" })
          end).to.throw("Invalid value for property")
        end)
        it("should error when 'isStrict' property of args[1] ~= boolean or nil", function()
          expect(function()
            Resourceful({ isStrict = "wrong" })
          end).to.throw("Invalid value for property")
        end)
        it("should error when 'name' property of args[1] ~= string or nil", function()
          expect(function()
            Resourceful({ name = false })
          end).to.throw("Invalid value for property")
        end)
        it("should error when 'resources' property of args[1] ~= table or nil", function()
          expect(function()
            Resourceful({ resources = false })
          end).to.throw("Invalid value for property")
        end)
        it("should error when resources contains failing __init function", function()
          expect(function()
            return Resourceful({
              resources = {
                __init = function() error("custom error") end,
              },
              search = {},
            })
          end).to.throw("custom error")
        end)
        it("should error when 'search' property of args[1] ~= Instance, table, or nil", function()
          expect(function()
            Resourceful({ search = false })
          end).to.throw("Invalid value for property")
        end)
        it("should error when 'search' property of args[1] contains non-Instance", function()
          expect(function()
            Resourceful({ search = { false } })
          end).to.throw("Invalid value for property")
        end)
        it("should show library name in error message", function()
          expect(function()
            Resourceful({ name = "MyLibrary", search = 0 })
          end).to.throw("MyLibrary")
        end)
      end)
      describe("success", function()
        it("should succeed when args[1] == nil", function()
          expect(function()
            Resourceful()
          end).never.to.throw()
        end)
        it("should succeed when args[1] == table", function()
          expect(function()
            Resourceful({})
          end).never.to.throw()
        end)
        it("should succeed when 'isCached' property of args[1] == boolean", function()
          expect(function()
            Resourceful({ isCached = false })
          end).never.to.throw()
        end)
        it("should succeed when 'isStrict' property of args[1] == boolean", function()
          expect(function()
            Resourceful({ isStrict = false })
          end).never.to.throw()
        end)
        it("should succeed when 'name' property of args[1] == string", function()
          expect(function()
            Resourceful({ name = "Name" })
          end).never.to.throw()
        end)
        it("should succeed when 'resources' property of args[1] == table", function()
          expect(function()
            Resourceful({ resources = {} })
          end).never.to.throw()
        end)
        it("should succeed when 'search' property of args[1] == table", function()
          expect(function()
            Resourceful({ search = {} })
          end).never.to.throw()
        end)
        it("should succeed when 'search' property of args[1] == Instance", function()
          expect(function()
            Resourceful({ search = game })
          end).never.to.throw()
        end)
        it("should succeed when 'search' property of args[1] contains Instance", function()
          expect(function()
            Resourceful({ search = { game } })
          end).never.to.throw()
        end)
        it("should succeed when 'search' property of args[1] contains multiple Instance objects", function()
          expect(function()
            Resourceful({ search = { game, game.ReplicatedStorage } })
          end).never.to.throw()
        end)
      end)
    end)
    describe("resource acquisition", function()
      describe("errors", function()
        it("should error when acquired resources references circular dependency", function()
          expect(function()
            return Resourceful({
              resources = {
                prop = function(r) return r.prop end,
              },
              search = {},
            }).prop
          end).to.throw("circular dependency")
        end)
        it("should error when acquired resources invokes failing function", function()
          expect(function()
            return Resourceful({
              resources = {
                prop = function() error("custom error") end,
              },
              search = {},
            }).prop
          end).to.throw("custom error")
        end)
        it("should error when acquired resources invokes function that returns nil", function()
          expect(function()
            return Resourceful({
              resources = {
                prop = function() return nil end,
              },
              search = {},
            }).prop
          end).to.throw("strict mode")
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
            search = {},
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
            search = {},
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
            search = {},
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
              search = {},
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
              search = {},
            }).prop
          ).to.equal(result)
        end)
        it("should return a number resource", function()
          expect(
            Resourceful({
              resources = {
                prop = 5,
              },
              search = {},
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
              search = {},
            }).prop
          ).to.equal(val)
        end)
        it("should return a string resource", function()
          expect(
            Resourceful({
              resources = {
                prop = "prop",
              },
              search = {},
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
              search = {},
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
              search = {},
            }).require.prop
          end).to.throw("non-ModuleScript")
        end)
        it("should error when missing target is required in strict mode", function()
          expect(function()
            return Resourceful({
              isStrict = true,
              resources = {},
              search = {},
            }).require.prop
          end).to.throw("strict mode")
        end)
        it("should error when non-ModuleScript target is required", function()
          expect(function()
            return Resourceful({
              resources = {
                prop = false,
              },
              search = {},
            }).require.prop
          end).to.throw("non-ModuleScript")
        end)
        it("should error when ModuleScript target with error is required", function()
          expect(function()
            return Resourceful({
              resources = {},
              search = game.ServerScriptService.Tests.Resourceful,
            }).require.error_module
          end).to.throw("error requiring module")
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
              search = {},
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
              search = {},
            }).success_module
          end).to.throw("strict mode")
        end)
        it("should default to strict mode", function()
          expect(function()
            return Resourceful({
              resources = {},
              search = {},
            }).success_module
          end).to.throw("strict mode")
        end)
      end)
    end)
  end)
end