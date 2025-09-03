--!strict
--!optimize 2

local Token = require("../Utils/Token")
local AST = require("../Utils/AST")
local Parser = require("../Parser")

local Expression = {}

--[[

Order of Prescidence

// Boolean Comparison
// Numeric Comparision
// Additive			--TODO: All 3 of the following the same code. please change.
// Multiplicitive
// Exponents

// Call
// Member
// Primary

]]--

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
	local left = Expression:CallMemberExpression(parser)

	while parser:at().value == "^" do
		local operator = parser:eat().value
		local right = Expression:CallMemberExpression(parser)

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

function Expression:CallMemberExpression(parser: Parser.Parser): (AST.Expression)
	local member = Expression:MemberExpression(parser)

	if parser:at().kind == Token.fromType.OpenParenthesis then
		return Expression:CallExpression(parser, member)
	end

	return member
end

function Expression:CallExpression(parser: Parser.Parser, caller: AST.Expression): (AST.Expression)
	local start = caller.range[1]
	local finish
	local result = {
		kind = AST.fromType.CallExpression,
		caller = caller,
		arguments = parser:ParseArguments(),
	} :: AST.CallExpression
	finish = parser.previous.range[2]

	if parser:at().kind == Token.fromType.OpenParenthesis then
		result = Expression:CallExpression(parser, result) :: any
		finish = result.range[2]
	end

	result.range = {start, finish}
	return result
end

function Expression:MemberExpression(parser: Parser.Parser): (AST.Expression)
	local start = parser:at().range[1]
	local object = Expression:PrimaryExpression(parser)
	local finish

	while parser:at().kind == Token.fromType.Period or parser:at().kind == Token.fromType.OpenBracket do
		local operator = parser:eat()
		local property: AST.Expression, computed: boolean

		if operator.kind == Token.fromType.Period then
			computed = false
			property = Expression:PrimaryExpression(parser)
			finish = property.range[2]

			if property.kind ~= AST.fromType.IdentifierLiteral then
				--TODO: error
				error(`hey! that's not right!`)
			end
		else
			computed = true
			property = parser:ParseExpression()
			finish = parser:expect(Token.fromType.CloseBracket).range[2]
		end

		object = {
			kind = AST.fromType.MemberExpression,

			object = object,
			property = property,
			computed = computed,

			range = {start, finish}
		} :: AST.MemberExpression
	end

	return object
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
	elseif token.kind == Token.fromType.Function then
		--TODO: might interfear with function definition statement
		local start = parser:eat().range[1]
		local parameters = {}

		for _, value in pairs(parser:ParseArguments()) do
			if value.kind ~= AST.fromType.IdentifierLiteral then
				error("fail")
			end

			table.insert(parameters, (value :: AST.IdentifierLiteral).value :: string)
		end

		local body, finish = parser:ParseBlock()

		return {
			kind = AST.fromType.FunctionLiteral,
			value = body,
			parameters = parameters,
			range = {start, finish}
		} :: AST.FunctionLiteral
	else
		print(token)
		error(`Unexpected token found during parsing, {Token.fromKind[token.kind]}`)
	end
end

return Expression