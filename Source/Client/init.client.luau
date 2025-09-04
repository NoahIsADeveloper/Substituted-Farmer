--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared:FindFirstChild("Interpreter")) :: typeof(require("./Shared/Interpreter"))

local Source = [[
local x = {
	test = 10,
	["test"] = 123,
}

x.test
]]

Interpreter.interpret(Source)