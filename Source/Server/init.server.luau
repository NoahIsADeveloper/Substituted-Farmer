--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Libraries = require(Shared.Interpreter.Utils.Libraries)

Libraries.init()