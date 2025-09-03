--!strict
--!optimize 2
local Evaluation = require("@self/Evaluation")
local Environment = require("@self/Evaluation/Environment")
local Parser = require("@self/Parser")
local Lexer = require("@self/Lexer")

local Runtime = require("@self/Utils/Runtime")

local Interpreter = {}

function Interpreter.interpret(source: string, environment: Environment.Environment?): (Runtime.Value?)
	if not environment then
		local scope = Environment.new()
		scope:DeclareGlobals()
		environment = scope
	end

	local tokens, ast, result
	local function execute()
		tokens = Lexer.tokenize(source)
		ast = Parser.parse(tokens)
		result = Evaluation.run(ast, environment :: Environment.Environment)
	end

	local success: boolean?, errorMessage: string? = execute()

	if not success then warn(`Failed to execute {source} {debug.traceback(errorMessage, 0)}`) end
	print("Tokens:", tokens)
	print("AST:", ast)
	print("Environment:", environment)
	print("Result:", result)

	return result
end

return Interpreter