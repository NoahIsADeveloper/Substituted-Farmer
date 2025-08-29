--!strict
--!optimize 2

local Expressions
local Statements

local Environment = require("@self/Environment")

local AST = require("./Utils/AST")
local Debug = require("./Utils/Debug")
local Values = require("./Utils/Runtime")


local Evaluation = {}

function Evaluation.evaluateBody(body: {AST.Statement}, environment: Environment.Environment): (Values.Value)
	local lastValue = Values:None()

	for _, node: AST.Statement in pairs(body) do
		lastValue = Evaluation.evaluate(node, environment)
	end

	return lastValue
end

function Evaluation.evaluate(node: AST.Statement, environment: Environment.Environment): (Values.Value)
	if not Expressions then Expressions = require("@self/Expressions") :: any end
	if not Statements then Statements = require("@self/Statements") :: any end

	local kind: AST.NodeKind = node.kind

	-- // Literals
	if kind == AST.fromType.NumericLiteral then
		return Values:Number((node :: AST.NumericLiteral).value)
	elseif kind == AST.fromType.StringLiteral then
		return Values:String((node :: AST.StringLiteral).value)
	elseif kind == AST.fromType.BooleanLiteral then
		return Values:Boolean((node :: AST.BooleanLiteral).value)
	elseif kind == AST.fromType.ArrayLiteral then
		return Values:Array((node :: AST.ArrayLiteral).value)
	elseif kind == AST.fromType.FunctionLiteral then
		return Values:Function((node :: AST.FunctionLiteral).value, (node :: AST.FunctionLiteral).parameters)
	elseif kind == AST.fromType.IdentifierLiteral then
		return environment:LookupVariable((node :: AST.IdentifierLiteral).value)

	-- // Statements
	elseif kind == AST.fromType.VariableDeclaration then
		return Statements:VariableDeclaration(node :: AST.VariableDeclaration, environment)
	elseif kind == AST.fromType.VariableAssignment then
		return Statements:VariableAssignment(node :: AST.VariableAssignment, environment)
	elseif kind == AST.fromType.WhileStatement then
		return Statements:WhileStatement(node :: AST.WhileStatement, environment)
	elseif kind == AST.fromType.IfStatement then
		return Statements:IfStatement(node :: AST.IfStatement, environment)
	elseif kind == AST.fromType.FunctionDeclaration then
		return Statements:FunctionDeclaration(node :: AST.FunctionDeclaration, environment)
	elseif kind == AST.fromType.TryStatement then
		return Statements:TryStatement(node :: AST.TryStatement, environment)

	-- // Expressions
	elseif kind == AST.fromType.BinaryExpression then
		return Expressions:BinaryExpression(node :: AST.BinaryExpression, environment)
	elseif kind == AST.fromType.BooleanExpression then
		return Expressions:BooleanExpression(node :: AST.BooleanExpression, environment)
	elseif kind == AST.fromType.CallExpression then
		return Expressions:CallExpression(node :: AST.CallExpression, environment)
	elseif kind == AST.fromType.MemberExpression then
		return Expressions:MemberExpression(node :: AST.MemberExpression, environment)

	-- // Program
	elseif kind == AST.fromType.Program then
		return Evaluation.evaluateBody((node :: AST.Program).body, environment)

	-- // Fail
	else
		Debug:Error(node, `Evaluation for '{AST.fromKind[node.kind]}' has not been setup yet.`)
		return Values:None()
	end
end

return Evaluation