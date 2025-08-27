--!strict
--!optimize 2

local Environment = require("../Environment")
local AST = require("../Utils/AST")
local Values = require("../Utils/Runtime")

local Evaluation = require("../Evaluation")

local Statement = {}

function Statement:VariableDeclaration(node: AST.VariableDeclaration, environment: Environment.Environment): (Values.NoneValue)
	if node.global then
		environment = environment:Resolve()
	end

	environment:DeclareVariable(
		node.identifier,
		if node.value then Evaluation.evaluate(node.value, environment) else Values:None(),
		node.immutable
	)

	return Values:None()
end

function Statement:FunctionDeclaration(node: AST.FunctionDeclaration, environment: Environment.Environment): (Values.NoneValue)
	if node.global then
		environment = environment:Resolve()
	end

	environment:DeclareVariable(
		node.name,
		Values:Function(node.body, node.parameters),
		false
	)

	return Values:None()
end

function Statement:VariableAssignment(node: AST.VariableAssignment, environment: Environment.Environment): (Values.NoneValue)
	local identifier = node.identifier
	local value = Evaluation.evaluate(node.value, environment)

	environment:AssignVariable(identifier, value)

	return Values:None()
end

function Statement:IfStatement(node: AST.IfStatement, environment: Environment.Environment): (Values.NoneValue)
	if Evaluation.evaluate(node.condition, environment).value then
		Evaluation.evaluateBody(node.body, environment)
	elseif node.alternate then
		Evaluation.evaluateBody(node.alternate, environment)
	end

	return Values:None()
end

function Statement:WhileStatement(node: AST.WhileStatement, environment: Environment.Environment): (Values.NoneValue)
	local running = true
	while running and Evaluation.evaluate(node.condition, environment).value do
		for _, statement in pairs(node.body) do
			if statement.kind == AST.fromType.ContinueStatement then break end
			if statement.kind == AST.fromType.BreakStatement then running = false; break end
			Evaluation.evaluate(statement, environment:new())
		end
	end

	if node.alternate then
		Evaluation.evaluateBody(node.alternate, environment:new())
	end

	return Values:None()
end

return Statement