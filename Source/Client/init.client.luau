--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared:FindFirstChild("Interpreter")) :: typeof(require("./Shared/Interpreter"))

local Source = [[
local index = 0
local function run() {
	index += 1

	if (index < 10) {
		run()
	} else {
		global x = false + true
	}
}

run()
]]

Interpreter.interpret(Source)