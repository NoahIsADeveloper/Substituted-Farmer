--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared:FindFirstChild("Interpreter")) :: typeof(require("./Shared/Interpreter"))

local Source = [[
local x
if (false) {
	x = 123
} else if (false) {
	x = 456
} else {
	x = 789
}
x
]]

Interpreter.interpret(Source)