--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared.Interpreter)

local Source = [[
3 ^ 2 + 3 * 4
]]

Interpreter:Interpret(Source)