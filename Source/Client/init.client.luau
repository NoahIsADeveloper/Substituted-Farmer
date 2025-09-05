--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared:FindFirstChild("Interpreter")) :: typeof(require("./Shared/Interpreter"))

local Source = [[
import "input"

input.inputBegan(function (key) {
	if (key == "W") {
		print("Forward")
	} else if (key == "S") {
		print("Backwards")
	} else if (key == "A") {
		print("Left")
	} else if (key == "D") {
		print("Right")
	}
})
]]

Interpreter.interpret(Source)