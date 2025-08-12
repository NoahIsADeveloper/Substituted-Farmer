--!strict
--!optimize 2

local AST = require("./Utils/AST")
local Values = require("./Utils/Runtime")

local Evaluation = {}

function Evaluation.evaluate(node: AST.Statement): (Values.Value)
	local kind: AST.NodeKind = node.kind

	-- // Literals
	if kind == AST.fromType.NumericLiteral then
		return Values:Number((node :: AST.NumericLiteral).value)
	elseif kind == AST.fromType.StringLiteral then
		return Values:Number((node :: AST.StringLiteral).value)

	-- // Program
	elseif kind == AST.fromType.Program then
		local lastEvaluated: Values.Value = Values:None()

		for _, statement in pairs((node :: AST.Program).body) do
			lastEvaluated = Evaluation.evaluate(statement)
		end

		return lastEvaluated

	-- // Fail
	else
		print(node)
		error("Fail")
	end
end

return Evaluation