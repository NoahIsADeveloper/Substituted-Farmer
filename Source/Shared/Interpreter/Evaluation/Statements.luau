--!strict
--!optimize 2

local Environment = require("../Environment")
local AST = require("../Utils/AST")
local Values = require("../Utils/Runtime")

local Evaluation = require("../Evaluation")

local Statement = {}

function Statement:VariableDeclaration(node: AST.VariableDeclaration, environment: Environment.Environment): ()
	environment:DeclareVariable(
		node.identifier.value,
		if node.value then Evaluation.evaluate(node, environment) else Values:None(),
		node.immutable
	)

	return Values:None()
end

return Statement