--!strict
--!optimize 2

local Token = require("../Utils/Token")
local AST = require("../Utils/AST")
local Parser = require("../Parser")

local Expression = {}

function Expression:AdditiveExpression(parser: Parser.Parser): (AST.Expression)
	local left = Expression:MultiplicitaveExpression(parser)

	while parser:at().value == "+" or parser:at().value == "-" do
		local operator = parser:eat().value
		local right = Expression:MultiplicitaveExpression(parser)

		left = {
			kind = AST.fromType.BinaryExpression,

			left = left,
			right = right,
			operator = operator,
		} :: AST.BinaryExpression
	end

	return left
end

function Expression:MultiplicitaveExpression(parser: Parser.Parser): (AST.Expression)
	local left = Expression:ExponentiationExpression(parser)

	while parser:at().value == "*" or parser:at().value == "/" or parser:at().value == "%" do
		local operator = parser:eat().value
		local right = Expression:ExponentiationExpression(parser)

		left = {
			kind = AST.fromType.BinaryExpression,

			left = left,
			right = right,
			operator = operator,
		} :: AST.BinaryExpression
	end

	return left
end

function Expression:ExponentiationExpression(parser: Parser.Parser): (AST.Expression)
	local left = Expression:PrimaryExpression(parser)

	while parser:at().value == "^" do
		local operator = parser:eat().value
		local right = Expression:PrimaryExpression(parser)

		left = {
			kind = AST.fromType.BinaryExpression,

			left = left,
			right = right,
			operator = operator,
		} :: AST.BinaryExpression
	end

	return left
end

function Expression:PrimaryExpression(parser: Parser.Parser): (AST.Expression)
	local token = parser:at()

	if token.kind == Token.fromType.Identifier then
		return {kind = AST.fromType.Identifier, value = parser:eat().value} :: AST.Identifier
	elseif token.kind == Token.fromType.Number then
		return {kind = AST.fromType.NumericLiteral, value = parser:eat().value} :: AST.NumericLiteral
	elseif token.kind == Token.fromType.String then
		return {kind = AST.fromType.StringLiteral, value = parser:eat().value} :: AST.StringLiteral
	elseif token.kind == Token.fromType.Boolean then
		return {kind = AST.fromType.BooleanLiteral, value = (parser:eat().value == "true")} :: AST.BooleanLiteral
	elseif token.kind == Token.fromType.None then
		parser:eat()
		return {kind = AST.fromType.NoneLiteral} :: AST.NoneLiteral
	else
		error("Unexpected token found during parsing")
	end
end

return Expression