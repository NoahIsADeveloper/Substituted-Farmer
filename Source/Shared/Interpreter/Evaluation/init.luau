--!strict
--!optimize 2

local Expressions
local Statements

local Environment = require("@self/Environment")
local Stack = require("@self/Stack")

local AST = require("./Utils/AST")
local Values = require("./Utils/Runtime")

local ASTTypes = AST.fromType

local Evaluation = {}
export type EvaluationData = {
	environment: Environment.Environment,
	stack: Stack.Stack,
	failData: {range: {number}, message: string, name: string}?,
}

local Evaluators = {
	-- // Literals
	[ASTTypes.NumericLiteral] = function(node: AST.NumericLiteral, data)
		return Values:Number(node.value)
	end,
	[ASTTypes.StringLiteral] = function(node: AST.StringLiteral, data)
		return Values:String(node.value)
	end,
	[ASTTypes.BooleanLiteral] = function(node: AST.BooleanLiteral, data)
		return Values:Boolean(node.value)
	end,
	[ASTTypes.ArrayLiteral] = function(node: AST.ArrayLiteral, data)
		return Values:Array(node.value)
	end,
	[ASTTypes.FunctionLiteral] = function(node: AST.FunctionLiteral, data)
		return Values:Function(node.value, node.parameters)
	end,
	[ASTTypes.IdentifierLiteral] = function(node: AST.IdentifierLiteral, data)
		return data.environment:LookupVariable(node.value)
	end,

	-- // Statements
	[ASTTypes.VariableDeclaration] = function(node: AST.VariableDeclaration, data)
		return Statements:VariableDeclaration(node, data)
	end,
	[ASTTypes.WhileStatement] = function(node: AST.WhileStatement, data)
		return Statements:WhileStatement(node, data)
	end,
	[ASTTypes.VariableAssignment] = function(node: AST.VariableAssignment, data)
		return Statements:VariableAssignment(node, data)
	end,
	[ASTTypes.IfStatement] = function(node: AST.IfStatement, data)
		return Statements:IfStatement(node, data)
	end,
	[ASTTypes.FunctionDeclaration] = function(node: AST.FunctionDeclaration, data)
		return Statements:FunctionDeclaration(node, data)
	end,
	[ASTTypes.TryStatement] = function(node: AST.TryStatement, data)
		return Statements:TryStatement(node, data)
	end,

	-- // Expressions
	[AST.fromType.BinaryExpression] = function(node: AST.BinaryExpression, data)
		return Expressions:BinaryExpression(node, data)
	end,
	[AST.fromType.BooleanExpression] = function(node: AST.BooleanExpression, data)
		return Expressions:BooleanExpression(node, data)
	end,
	[AST.fromType.CallExpression] = function(node: AST.CallExpression, data)
		return Expressions:CallExpression(node, data)
	end,
	[AST.fromType.MemberExpression] = function(node: AST.MemberExpression, data)
		return Expressions:MemberExpression(node, data)
	end,

	-- // Program
	[ASTTypes.Program] = function(node: AST.Program, data)
		return Evaluation["evaluateBody"](node.body, data)
	end
} :: {(node: any, data: EvaluationData) -> (Values.Value)}

function Evaluation.up(data: EvaluationData)
	local scope = data.environment:new()
	data.environment = scope
end

function Evaluation.down(data: EvaluationData)
	local scope = data.environment.parent :: Environment.Environment
	data.environment = scope
end

function Evaluation.fail(data: EvaluationData, message: string, node: AST.Statement)
	data.failData = {
		range = node.range,
		message = message,
		name = AST.fromKind[node.kind] :: string,
	}
	print(data.failData)
	error(message)
end

function Evaluation.evaluateBody(body: {AST.Statement}, data: EvaluationData): (Values.Value)
	local lastValue = Values:None()

	for _, node: AST.Statement in pairs(body) do
		lastValue = Evaluation.evaluate(node, data)
	end

	return lastValue
end

function Evaluation.evaluate(node: AST.Statement, data: EvaluationData): (Values.Value)
	if not Expressions then Expressions = require("@self/Expressions") :: any end
	if not Statements then Statements = require("@self/Statements") :: any end

	local kind: AST.NodeKind = node.kind
	local call = Evaluators[kind]

	if call then
		return call(node, data)
	end

	error(`Cannot evaluate node '{AST.fromKind[node.kind]}' as it has not been set up yet.`)
	return Values:None()
end

function Evaluation.run(node: AST.Program, environment: Environment.Environment): (Values.Value)
	local stack = Stack.new()
	local evaluationData = {
		environment = environment,
		stack = stack,
	} :: EvaluationData

	local success, result = pcall(function()
		return Evaluation.evaluate(node, evaluationData)
	end)

	if not success then
		--TODO: CANCER
		local message = if evaluationData.failData then evaluationData.failData.message else result :: any
		local location = if evaluationData.failData then evaluationData.failData.range else node.range
		local name = if evaluationData.failData then evaluationData.failData.name else AST.fromKind[node.kind]

		warn(stack:Out(message, location, name))
		return Values:None()
	end

	return result
end

return Evaluation