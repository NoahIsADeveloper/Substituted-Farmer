--!strict
--!optimize 2

local Environment = require("./Environment")
local AST = require("../Utils/AST")
local Values = require("../Utils/Runtime")
local Operators = require("../Utils/Operations")
local Debug = require("../Utils/Debug")

local Evaluation = require("../Evaluation")

local Expression = {}

function Expression:BinaryExpression(node: AST.BinaryExpression, environment: Environment.Environment): (Values.Value)
	local left = Evaluation.evaluate(node.left, environment) :: Values.Value
	local right = Evaluation.evaluate(node.right, environment) :: Values.Value
	local operator = node.operator
	local call = Operators[operator]

	--TODO: better error messages
	if not call then Debug:Error(node, `error 1`) end
	if left.kind ~= right.kind then Debug:Error(node, `error 2`) end

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

	Debug:Error(node, `Cannot compute '{AST.fromKind[node.left.kind]} {node.operator} {AST.fromKind[node.right.kind]}'`)
	return Values:None()
end

function Expression:MemberExpression(node: AST.MemberExpression, environment: Environment.Environment, member: AST.MemberExpression?): (Values.Value)
	--TODO: doo doo dogshit please fixy thank you
	local object = Evaluation.evaluate(node.object, environment)
	local property

	if node.computed then
		property = (node.property :: AST.IdentifierLiteral).value
	else
		property = Evaluation.evaluate(node.property, environment).value
	end

	if object.value[property] then
		return object.value[property]
	end

	return Values:None()
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

	Debug:Error(node, `Boolean operator "{node.operator}" is invalid `)
	return Values:None()
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
		Debug:Error(node, `Cannot call {AST.fromKind[caller.kind]} value`)
		return Values:None()
	end
end

return Expression