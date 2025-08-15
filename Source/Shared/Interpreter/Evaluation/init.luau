--!strict
--!optimize 2

local Expressions
local Statements

local Environment = require("./Environment")

local AST = require("./Utils/AST")
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

	-- // Expressions
	elseif kind == AST.fromType.BinaryExpression then
		return Expressions:BinaryExpression(node :: AST.BinaryExpression, environment)
	elseif kind == AST.fromType.BooleanExpression then
		return Expressions:BooleanExpression(node :: AST.BooleanExpression, environment)

	-- // Program
	elseif kind == AST.fromType.Program then
		return Evaluation.evaluateBody((node :: AST.Program).body, environment)

	-- // Fail
	else
		print(node, AST.fromKind[node.kind])
		error(`Fail: ({node.range[1]}->{node.range[2]})`)
	end
end

return Evaluation