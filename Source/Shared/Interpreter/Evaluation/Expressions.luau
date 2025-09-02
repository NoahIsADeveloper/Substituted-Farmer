--!strict
--!optimize 2

local AST = require("../Utils/AST")
local Values = require("../Utils/Runtime")
local Operators = require("../Utils/Operations")

local Evaluation = require("../Evaluation")

local Expression = {}

function Expression:BinaryExpression(node: AST.BinaryExpression, data: Evaluation.EvaluationData): (Values.Value)
	local left = Evaluation.evaluate(node.left, data) :: Values.Value
	local right = Evaluation.evaluate(node.right, data) :: Values.Value
	local operator = node.operator
	local call = Operators[operator]

	if not call then Evaluation.fail(data, `Operator {operator} is not a valid operator`, node); return Values:None() end
	if left.kind ~= right.kind then Evaluation.fail(data, `Cannot run operation {operator} on a {AST.fromKind[node.left.kind]} value and a {AST.fromKind[node.right.kind]} value`, node); return Values:None() end

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

	Evaluation.fail(data, `Cannot compute '{AST.fromKind[node.left.kind]} {node.operator} {AST.fromKind[node.right.kind]}'`, node)
	return Values:None()
end

function Expression:MemberExpression(node: AST.MemberExpression, data: Evaluation.EvaluationData, member: AST.MemberExpression?): (Values.Value)
	--TODO: doo doo dogshit please fixy thank you
	local object = Evaluation.evaluate(node.object, data)
	local property

	if node.computed then
		property = (node.property :: AST.IdentifierLiteral).value
	else
		property = Evaluation.evaluate(node.property, data).value
	end

	if object.value[property] then
		return object.value[property]
	end

	return Values:None()
end

function Expression:BooleanExpression(node: AST.BooleanExpression, data: Evaluation.EvaluationData): (Values.Value)
	local left = Evaluation.evaluate(node.left, data) :: Values.Value
	local right = Evaluation.evaluate(node.right, data) :: Values.Value
	local operator = node.operator

	if operator == "and" then
		return left.value and right.value
	elseif operator == "or" then
		return left.value or right.value
	end

	Evaluation.fail(data, `Boolean operator "{node.operator}" is invalid`, node)
	return Values:None()
end

function Expression:CallExpression(node: AST.CallExpression, data: Evaluation.EvaluationData): (Values.Value)
	local caller = Evaluation.evaluate(node.caller, data)

	local result
	local arguments = {}

	for index, argument in pairs(node.arguments) do
		table.insert(arguments, Evaluation.evaluate(argument, data))
	end

	Evaluation.up(data)
	data.stack:Push(node)

	if caller.kind == Values.fromType.FunctionValue then
		result = Evaluation.evaluateBody((caller :: Values.FunctionValue).value, data)
	elseif caller.kind == Values.fromType.NativeFunctionValue then
		result = (caller :: Values.NativeFunctionValue).value(data, arguments) or Values:None()
	else
		Evaluation.fail(data, `Attempted to call a {AST.fromKind[caller.kind]} value`, node)
		return Values:None()
	end

	Evaluation.down(data)
	return result
end

return Expression