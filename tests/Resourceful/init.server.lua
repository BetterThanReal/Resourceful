local TestEZ = require(game.ReplicatedStorage.TestEZ)

local testLocations = {
    game.ReplicatedStorage.Scripts,
}

local reporter = TestEZ.TextReporter
 
TestEZ.TestBootstrap:run(testLocations, reporter)