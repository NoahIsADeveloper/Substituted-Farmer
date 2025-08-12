--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interpreter = require(Shared.Interpreter)

local Source = [[
35 ^ 2 / 35
]]

Interpreter:Interpret(Source)