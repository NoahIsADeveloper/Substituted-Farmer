--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lexer = require(ReplicatedStorage:WaitForChild("Shared").Interpreter.Frontend.Lexer)

print(Lexer.tokenize([[
"Test"
190823
]]))

print(require(ReplicatedStorage:WaitForChild("Shared").Utils.Token).fromKind)