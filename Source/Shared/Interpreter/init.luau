--!strict
--!optimize 2
local Environment = require("@self/Environment")
local Evaluation = require("@self/Evaluation")
local Parser = require("@self/Parser")
local Lexer = require("@self/Lexer")

local Runtime = require("@self/Utils/Runtime")

local Module = {}

function Module:Interpret(source: string, environment: Environment.Environment?): (Runtime.Value?)
	if not environment then
		environment = Environment.new()
	end

	local tokens, ast, result
	local success, errorMessage = pcall(function()
		tokens = Lexer.tokenize(source)
		ast = Parser.parse(tokens)
		result = Evaluation.evaluate(ast, environment :: Environment.Environment)
	end)

	if not success then warn(`Failed to execute {source} {debug.traceback(errorMessage)}`) end
	print("Tokens:", tokens)
	print("AST:", ast)
	print("Result:", result)

	return result
end

return Module