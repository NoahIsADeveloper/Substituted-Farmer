--!strict
--!optimize 2

local Token = require("../Utils/Token")
local AST = require("../Utils/AST")
local Parser = require("../Parser")

local Statement = {}

function Statement:VariableDeclaration(parser: Parser.Parser)
	local global = parser:eat().kind == Token.fromType.Global
	local identifier = parser:expect(Token.fromType.Identifier)

	if parser:at().kind == Token.fromType.Assign then
		parser:eat()
		return {
			kind = AST.fromType.VariableDeclaration,
			immutable = false,
			global = global,
			value = parser:ParseExpression() :: any,
		} :: AST.VariableDeclaration
	end

	return {
		kind = AST.fromType.VariableDeclaration,
		immutable = false,
		global = global,
		value = nil :: any,
	} :: AST.VariableDeclaration
end

return Statement