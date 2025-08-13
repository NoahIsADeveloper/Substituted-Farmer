--!strict
--!optimize 2

local Expressions
local Statements

local Environment = require("./Environment")

local AST = require("./Utils/AST")
local Values = require("./Utils/Runtime")

local Evaluation = {}

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
	elseif kind == AST.fromType.Identifier then
		return Environment:LookupVariable((node :: AST.Identifier).value)

	-- // Expressions
	elseif kind == AST.fromType.BinaryExpression then
		return Expressions:BinaryExpression(node :: AST.BinaryExpression, environment)
	elseif kind == AST.fromType.BooleanExpression then
		return Expressions:BooleanExpression(node :: AST.BooleanExpression, environment)

	-- // Statements
	elseif kind == AST.fromType.VariableDeclaration then
		return Statements:VariableDeclaration(node :: AST.VariableDeclaration, environment)

	-- // Program
	elseif kind == AST.fromType.Program then
		local lastEvaluated: Values.Value = Values:None()

		for _, statement in pairs((node :: AST.Program).body) do
			lastEvaluated = Evaluation.evaluate(statement, environment)
		end

		return lastEvaluated

	-- // Fail
	else
		print(node, AST.fromKind[node.kind])
		error("Fail")
	end
end

return Evaluation