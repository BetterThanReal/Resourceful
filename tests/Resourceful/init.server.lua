-- Valid example names: 
-- ErrorCircular, ErrorFunction, ErrorInvalidModule, ErrorModule, ErrorNil,
-- ErrorNotFound
local runExample = false

if type(runExample) == 'string' then
  require(script.examples)(runExample)
else
  local TestEZ = require(game.ReplicatedStorage.TestEZ)
  local testLocations = { game.ReplicatedStorage.Scripts }
  local reporter = TestEZ.TextReporter
  TestEZ.TestBootstrap:run(testLocations, reporter)
end