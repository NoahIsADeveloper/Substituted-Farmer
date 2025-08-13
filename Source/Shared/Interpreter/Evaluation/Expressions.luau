--!strict
--!optimize 2

local Environment = require("../Environment")
local AST = require("../Utils/AST")
local Values = require("../Utils/Runtime")
local Operators = require("../Utils/Operations")

local Evaluation = require("../Evaluation")

local Expression = {}

function Expression:BinaryExpression(node: AST.BinaryExpression, environment: Environment.Environment): (Values.Value)
	local left = Evaluation.evaluate(node.left, environment) :: Values.Value
	local right = Evaluation.evaluate(node.right, environment) :: Values.Value
	local operator = node.operator
	local call = Operators[operator]

	assert(call, `error msg`)
	assert(left.kind == right.kind, `error msg 2`)

	if left.kind == Values.fromType.NumberValue then
		local result = call(left.value, right.value)

		if type(result) == "number" then
			return Values:Number(result)
		elseif type(result) == "boolean" then
			return Values:Boolean(result)
		end
	elseif left.kind == Values.fromType.StringValue then
		if operator == "+" then
			return Values:String(left.value .. right.value)
		elseif operator:sub(1, 1) == ">" or operator:sub(1, 1) == "<" then
			return Values:Boolean(call(left.value, right.value))
		end
	end

	--TODO: better error message
	print(left.kind, right.kind, AST.fromKind[left.kind], AST.fromKind[right.kind])
	error("nuh uh")
end

return Expression