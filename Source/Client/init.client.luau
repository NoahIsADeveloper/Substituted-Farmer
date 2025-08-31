--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared:FindFirstChild("Interpreter")) :: typeof(require("./Shared/Interpreter"))

local Source = [[
local function test() {
	local x = 5 + true
}

test()
]]

Interpreter.interpret(Source)