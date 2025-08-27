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
	error("nuh uh")
end

function Expression:MemberExpression(node: AST.MemberExpression, environment: Environment.Environment, member: AST.MemberExpression?): (Values.Value)
	--TODO: better error message
	error(`dsakl`)
end

function Expression:BooleanExpression(node: AST.BooleanExpression, environment: Environment.Environment): (Values.Value)
	local left = Evaluation.evaluate(node.left, environment) :: Values.Value
	local right = Evaluation.evaluate(node.right, environment) :: Values.Value
	local operator = node.operator

	if operator == "and" then
		return left.value and right.value
	elseif operator == "or" then
		return left.value or right.value
	end

	--TODO: better error message
	error("wuh uh")
end

function Expression:CallExpression(node: AST.CallExpression, environment: Environment.Environment): (Values.Value)
	local caller = Evaluation.evaluate(node.caller, environment)

	local scope = environment:new()
	local arguments = {}

	for _, argument in pairs(node.arguments) do
		table.insert(arguments, Evaluation.evaluate(argument, environment))
	end

	if caller.kind == Values.fromType.FunctionValue then
		return Evaluation.evaluateBody((caller :: Values.FunctionValue).value, scope)
	elseif caller.kind == Values.fromType.NativeFunctionValue then
		return (caller :: Values.NativeFunctionValue).value(scope)
	else
		--TODO: better error message
		error(`bad`)
	end
end

return Expression