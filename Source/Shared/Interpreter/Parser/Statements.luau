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

return Statement