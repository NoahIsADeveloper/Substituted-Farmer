--!strict
--!optimize 2

local Token = require("../Utils/Token")
local AST = require("../Utils/AST")
local Parser = require("../Parser")

local Statement = {}

function Statement:VariableDeclaration(parser: Parser.Parser)
	local start = parser:at().range[1]
	local global = parser:eat().kind == Token.fromType.Global
	local finish = parser:at().range[2]
	local identifier = parser:expect(Token.fromType.Identifier)

	if parser:at().kind == Token.fromType.Assign then
		finish = parser:eat().range[2]
		return {
			kind = AST.fromType.VariableDeclaration,
			immutable = false,
			identifier = identifier.value,
			global = global,
			value = parser:ParseExpression() :: any,
			range = {start, finish},
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

return Statement