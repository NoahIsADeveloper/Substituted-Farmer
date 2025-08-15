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

function Statement:VariableAssignment(node: AST.VariableAssignment, environment: Environment.Environment): (Values.NoneValue)
	local identifier = node.identifier
	local value = Evaluation.evaluate(node.value, environment)

	environment:AssignVariable(identifier, value)

	return Values:None()
end

return Statement