--!strict
--!optimize 2

local Token = require("../Utils/Token")
local AST = require("../Utils/AST")
local Parser = require("../Parser")

local Statement = {}

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
	local body = Statement:ParseBlock(parser)
	local alternate
	local finish = body[#body].range[2]

	if parser:at().kind == Token.fromType.Else then
		parser:eat()
		alternate = Statement:ParseBlock(parser)
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
	local body = Statement:ParseBlock(parser)
	local alternate
	local finish = body[#body].range[2]

	if parser:at().kind == Token.fromType.Else then
		parser:eat()

		if parser:at().kind == Token.fromType.If then
			alternate = {Statement:IfStatement(parser)}
		else
			alternate = Statement:ParseBlock(parser) :: any
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

function Statement:ParseBlock(parser: Parser.Parser): ({AST.Statement})
	local body: {AST.Statement} = {}
	parser:expect(Token.fromType.OpenBrace)

	while parser:at().kind ~= Token.fromType.CloseBrace do
		local statement = parser:ParseStatement()
		table.insert(body, statement)
	end

	parser:expect(Token.fromType.CloseBrace)
	return body
end

return Statement