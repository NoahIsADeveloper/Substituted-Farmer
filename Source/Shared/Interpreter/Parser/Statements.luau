--!strict
--!optimize 2

local Token = require("../Utils/Token")
local AST = require("../Utils/AST")
local Parser = require("../Parser")

local Statement = {}

function Statement:TryStatement(parser: Parser.Parser): (AST.TryStatement)
	local start = parser:expect(Token.fromType.Try).range[1]
	local body, finish = parser:ParseBlock()
	local alternate
	local symbol

	if parser:at().kind == Token.fromType.Else then
		parser:eat()

		if parser:at().kind == Token.fromType.Identifier then
			symbol = parser:eat().value
		end

		alternate, finish = parser:ParseBlock()
	end

	return {
		kind = AST.fromType.TryStatement,
		body = body,
		alternate = alternate :: any,
		symbol = symbol,

		range = {start, finish},
	} :: AST.TryStatement
end

function Statement:FunctionDeclaration(parser: Parser.Parser): (AST.FunctionDeclaration)
	local global = true
	if parser:at().kind == Token.fromType.Global or parser:at().kind == Token.fromType.Local then
		global = parser:at().value == Token.fromType.Global
	end

	local start = parser:eat().range[1]
	parser:expect(Token.fromType.Function)

	local identifier = parser:expect(Token.fromType.Identifier)
	local parameters = {}

	for _, value in pairs(parser:ParseArguments()) do
		if value.kind ~= AST.fromType.IdentifierLiteral then
			error("fail")
		end

		table.insert(parameters, (value :: AST.IdentifierLiteral).value :: string)
	end

	local body = parser:ParseBlock()

	return {
		kind = AST.fromType.FunctionDeclaration,
		parameters = parameters,
		name = identifier.value,
		body = body,
		global = global,

		range = {start, body[#body].range[2]}
	} :: AST.FunctionDeclaration
end

function Statement:VariableDeclaration(parser: Parser.Parser): (AST.VariableDeclaration)
	local start = parser:at().range[1]
	local global = parser:eat().kind == Token.fromType.Global
	local finish = parser:at().range[2]
	local identifier = parser:expect(Token.fromType.Identifier)

	if parser:at().kind == Token.fromType.Assign then
		parser:eat()
		local value = parser:ParseExpression()
		return {
			kind = AST.fromType.VariableDeclaration,
			immutable = false,
			identifier = identifier.value,
			global = global,
			value = value :: any,
			range = {start, value.range[2]},
		} :: AST.VariableDeclaration
	end

	return {
		kind = AST.fromType.VariableDeclaration,
		immutable = false,
		identifier = identifier.value,
		global = global,
		value = nil :: any,
		range = {start, finish},
	} :: AST.VariableDeclaration
end

function Statement:VariableAssignment(parser: Parser.Parser): (AST.VariableAssignment)
	local identifier = parser:eat()
	parser:expect(Token.fromType.Assign)
	local value = parser:ParseExpression()

	return {
		kind = AST.fromType.VariableAssignment,
		range = {identifier.range[1], value.range[2]},
		identifier = identifier.value,
		value = value,
	} :: (AST.VariableAssignment)
end

function Statement:VariableCompoundAssignment(parser: Parser.Parser): (AST.VariableAssignment)
	local identifier = parser:eat()
	local assignment = parser:expect(Token.fromType.CompoundAssign)
	local value = parser:ParseExpression()

	return {
		kind = AST.fromType.VariableAssignment,
		range = {identifier.range[1], value.range[2]},
		identifier = identifier.value,
		value = {
			kind = AST.fromType.BinaryExpression,
			left = {kind = AST.fromType.Identifier, value = identifier.value, range = identifier.range} :: any,
			right = value,
			operator = (assignment.value :: string):sub(1, 1) :: string,
		} :: AST.BinaryExpression,
	} :: any
end

function Statement:WhileStatement(parser: Parser.Parser): (AST.WhileStatement)
	local start = parser:expect(Token.fromType.While).range[1]
	parser:expect(Token.fromType.OpenParenthesis)
	local condition = parser:ParseExpression()
	parser:expect(Token.fromType.CloseParenthesis)
	local body = parser:ParseBlock()
	local alternate
	local finish = body[#body].range[2]

	if parser:at().kind == Token.fromType.Else then
		parser:eat()
		alternate = parser:ParseBlock()
		finish = alternate[#alternate].range[2]
	end

	return {
		kind = AST.fromType.WhileStatement,
		condition = condition,
		body = body,
		alternate = alternate,
		range = {start, finish}
	} :: any
end

function Statement:IfStatement(parser: Parser.Parser): (AST.IfStatement)
	local start = parser:expect(Token.fromType.If).range[1]
	parser:expect(Token.fromType.OpenParenthesis)
	local condition = parser:ParseExpression()
	parser:expect(Token.fromType.CloseParenthesis)
	local body = parser:ParseBlock()
	local alternate
	local finish = body[#body].range[2]

	if parser:at().kind == Token.fromType.Else then
		parser:eat()

		if parser:at().kind == Token.fromType.If then
			alternate = {Statement:IfStatement(parser)}
		else
			alternate = parser:ParseBlock() :: any
		end

		finish = alternate[#alternate].range[2]
	end

	return {
		kind = AST.fromType.IfStatement,
		condition = condition,
		body = body,
		alternate = alternate,
		range = {start, finish}
	} :: any
end

return Statement