--!strict
--!optimize 2

local Token = require("../Utils/Token")
local AST = require("../Utils/AST")
local Parser = require("../Parser")

local Expression = {}

function Expression:BooleanComparisonExpression(parser: Parser.Parser): (AST.Expression)
	local left = Expression:NumericComparisonExpression(parser)

	while parser:at().kind == Token.fromType.BooleanOperator do
		local operator = parser:eat().value
		local right = Expression:NumericComparisonExpression(parser)

		left = {
			kind = AST.fromType.BooleanExpression,
			range = {left.range[1], right.range[2]},

			left = left,
			right = right,
			operator = operator,
		} :: AST.BooleanExpression
	end

	return left
end

function Expression:NumericComparisonExpression(parser: Parser.Parser): (AST.Expression)
	local left = Expression:AdditiveExpression(parser)

	while parser:at().kind == Token.fromType.Compare do
		local operator = parser:eat().value
		local right = Expression:AdditiveExpression(parser)

		left = {
			kind = AST.fromType.BinaryExpression,
			range = {left.range[1], right.range[2]},

			left = left,
			right = right,
			operator = operator,
		} :: AST.BinaryExpression
	end

	return left
end

function Expression:AdditiveExpression(parser: Parser.Parser): (AST.Expression)
	local left = Expression:MultiplicitaveExpression(parser)

	while parser:at().value == "+" or parser:at().value == "-" do
		local operator = parser:eat().value
		local right = Expression:MultiplicitaveExpression(parser)

		left = {
			kind = AST.fromType.BinaryExpression,
			range = {left.range[1], right.range[2]},

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
			range = {left.range[1], right.range[2]},

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
			range = {left.range[1], right.range[2]},

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
		return {kind = AST.fromType.IdentifierLiteral, value = token.value, range = parser:eat().range} :: AST.IdentifierLiteral
	elseif token.kind == Token.fromType.Number then
		return {kind = AST.fromType.NumericLiteral, value = token.value, range = parser:eat().range} :: AST.NumericLiteral
	elseif token.kind == Token.fromType.String then
		return {kind = AST.fromType.StringLiteral, value = token.value, range = parser:eat().range} :: AST.StringLiteral
	elseif token.kind == Token.fromType.Boolean then
		return {kind = AST.fromType.BooleanLiteral, value = (token.value == "true"), range = parser:eat().range} :: AST.BooleanLiteral
	elseif token.kind == Token.fromType.None then
		return {kind = AST.fromType.NoneLiteral, range = parser:eat().range} :: AST.NoneLiteral
	elseif token.kind == Token.fromType.OpenBracket then
		local value = {}
		local start = parser:eat().range[1]
		local finish = start

		while parser:at().kind ~= Token.fromType.CloseBracket do
			table.insert(value, parser:ParseExpression())

			if parser:at().kind ~= Token.fromType.CloseBracket then
				parser:expect(Token.fromType.Comma)
			else
				finish = parser:eat().range[2]
				break
			end
		end

		return {kind = AST.fromType.ArrayLiteral, value = value, range = {start, finish}}
	else
		print(token)
		error(`Unexpected token found during parsing, {Token.fromKind[token.kind]}`)
	end
end

return Expression