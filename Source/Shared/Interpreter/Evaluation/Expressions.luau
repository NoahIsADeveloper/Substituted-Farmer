--!strict
--!optimize 2

local AST = require("../Utils/AST")
local Values = require("../Utils/Runtime")
local Operators = require("../Utils/Operations")

local Evaluation = require("../Evaluation")

local Expression = {}

function Expression:BinaryExpression(node: AST.BinaryExpression): (Values.Value)
	local left = Evaluation.evaluate(node.left)
	local right = Evaluation.evaluate(node.right)
	local operator = node.operator

	if left.kind == right.kind then
		if left.kind == Values.fromType.NumberValue then
			local result = Operators[operator]((left :: AST.NumericLiteral).value, (right :: AST.NumericLiteral).value)

			if type(result) == "number" then
				return Values:Number(result)
			elseif type(result) == "boolean" then
				return Values:Boolean(result)
			else
				warn("b")
			end
		elseif left.kind == Values.fromType.StringValue then
			if operator == "+" then
				return Values:String((left :: AST.StringLiteral).value .. (right :: AST.StringLiteral).value)
			elseif operator:sub(1, 1) == ">" or operator:sub(1, 1) == "<" then
				return Values:Boolean(Operators[operator]((left :: AST.StringLiteral).value, (right :: AST.StringLiteral).value))
			else
				warn("c")
			end
		end
	end

	--TODO: better error message
	print(left.kind, right.kind, AST.fromKind[left.kind], AST.fromKind[right.kind])
	error("nuh uh")
end

return Expression