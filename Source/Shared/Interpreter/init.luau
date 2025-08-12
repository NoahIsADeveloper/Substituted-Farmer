--!strict
--!optimize 2
task.wait(.3)
local Evaluation = require("@self/Evaluation")
local Parser = require("@self/Parser")
local Lexer = require("@self/Lexer")

local Runtime = require("@self/Utils/Runtime")

local Module = {}

function Module:Interpret(source: string): (Runtime.Value?)
	local tokens, ast, result
	local success, errorMessage = pcall(function()
		tokens = Lexer.tokenize(source)
		ast = Parser.parse(tokens)
		result = Evaluation.evaluate(ast)
	end)

	if not success then warn(`Failed to execute {source} {debug.traceback(errorMessage)}`) end
	print("Tokens:", tokens)
	print("AST:", ast)
	print("Result:", result)

	return result
end

return Module