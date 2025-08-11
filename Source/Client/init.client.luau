--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Interpreter = ReplicatedStorage:WaitForChild("Shared").Interpreter
local Lexer = require(Interpreter.Lexer)
local Parser = require(Interpreter.Parser)

local Source = [[
190823 + 89123
]]

print(Lexer.tokenize(Source))
print(Parser.parse(Lexer.tokenize(Source)))