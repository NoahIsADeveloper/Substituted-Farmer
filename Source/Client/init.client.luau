--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared:FindFirstChild("Interpreter")) :: typeof(require("./Shared/Interpreter"))

local Source = [[
if (true) {
	123
} else if (false) {
	456
} else {
	789
}
]]

Interpreter.interpret(Source)