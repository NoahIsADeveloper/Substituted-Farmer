--!strict
--!optimize 2

local AST = require("../Utils/AST")
local Values = require("../Utils/Runtime")
local Evaluation = require("../Evaluation")

local Statement = {}

function Statement:VariableDeclaration(node: AST.VariableDeclaration, data: Evaluation.EvaluationData): (Values.NoneValue)
	local environment = data.environment
	if node.global then
		environment = data.environment:Resolve()
	end

	environment:DeclareVariable(
		node.identifier,
		if node.value then Evaluation.evaluate(node.value, data) else Values:None(),
		node.immutable
	)

	return Values:None()
end

function Statement:ImportStatement(node: AST.ImportStatement, data: Evaluation.EvaluationData): (Values.NoneValue)
	local environment = data.environment:Resolve()

	for _, name in pairs(node.imports) do
		
	end

	return Values:None()
end

function Statement:FunctionDeclaration(node: AST.FunctionDeclaration, data: Evaluation.EvaluationData): (Values.NoneValue)
	local environment = data.environment
	if node.global then
		environment = data.environment:Resolve()
	end

	environment:DeclareVariable(
		node.name,
		Values:Function(node.body, node.parameters),
		false
	)

	return Values:None()
end

function Statement:VariableAssignment(node: AST.VariableAssignment, data: Evaluation.EvaluationData): (Values.NoneValue)
	local identifier = node.identifier
	local value = Evaluation.evaluate(node.value, data)

	data.environment:AssignVariable(identifier, value)

	return Values:None()
end

function Statement:IfStatement(node: AST.IfStatement, data: Evaluation.EvaluationData): (Values.NoneValue)
	Evaluation.up(data)
	if Evaluation.evaluate(node.condition, data).value then
		Evaluation.evaluateBody(node.body, data)
	elseif node.alternate then
		Evaluation.evaluateBody(node.alternate, data)
	end
	Evaluation.down(data)

	return Values:None()
end

function Statement:TryStatement(node: AST.TryStatement, data: Evaluation.EvaluationData): (Values.NoneValue)
	Evaluation.up(data)
	local success: boolean, errorMessage: any = pcall(Evaluation.evaluateBody, node.body, data)
	Evaluation.down(data)

	if not success and node.alternate then
		--TODO: node.alternate
		Evaluation.up(data)
		if node.symbol then
			--TODO: CANCER
			local message = if data.failData then data.failData.message else errorMessage
			local location = if data.failData then data.failData.range else node.range
			local name = if data.failData then data.failData.name else AST.fromKind[node.kind]

			data.environment:DeclareVariable(node.symbol, Values:String(data.stack:Out(message, location, name)), true)
		end
		Evaluation.evaluateBody(node.alternate, data)
		Evaluation.down(data)
	end

	data.environment = data.environment.parent :: any
	return Values:None()
end

function Statement:WhileStatement(node: AST.WhileStatement, data: Evaluation.EvaluationData): (Values.NoneValue)
	local running = true
	while running and Evaluation.evaluate(node.condition, data).value do
		Evaluation.up(data)
		for _, statement in pairs(node.body) do
			if statement.kind == AST.fromType.ContinueStatement then break end
			if statement.kind == AST.fromType.BreakStatement then running = false; break end
			Evaluation.evaluate(statement, data)
		end
		Evaluation.down(data)
	end

	if node.alternate then
		Evaluation.up(data)
		Evaluation.evaluateBody(node.alternate, data)
		Evaluation.down(data)
	end

	return Values:None()
end

return Statement