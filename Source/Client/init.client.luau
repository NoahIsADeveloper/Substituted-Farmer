--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
task.wait(3)
local Interpreter = require(Shared.Interpreter)

local Source = [[
123 < 100
]]

Interpreter:Interpret(Source)