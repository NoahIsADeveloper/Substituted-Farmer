--!strict
--!optimize 2

local AST = require("./Utils/AST")
local Token = require("./Utils/Token")
local Statements
local Expressions

local Parser = {} :: Parser
export type Parser = typeof(setmetatable({} :: {
	__index: Parser,

	tokens: {Token.Token},
	index: number,
	previous: Token.Token,

	ParseStatement: (self: Parser, fails: boolean?) -> (AST.Statement),
	ParseExpression: (self: Parser) -> (AST.Statement),
	ParseArguments: (self: Parser) -> ({AST.Statement}),
	ParseBlock: (self: Parser) -> ({AST.Statement}, number),
	notEoF: (self: Parser) -> (boolean),
	expect: (self: Parser, expects: Token.TokenKind) -> (Token.Token),
	next: (self: Parser) -> (Token.Token),
	at: (self: Parser) -> (Token.Token),
	peer: (self: Parser) -> (Token.Token),
	eat: (self: Parser) -> (Token.Token),

	new: (tokens: {Token.Token}) -> (Parser),
	parse: (tokens: {Token.Token}) -> (AST.Program),
}, Parser))
Parser.__index = Parser

function Parser:notEoF(): (boolean)
	return self:at().kind ~= Token.fromType.EoF
end

local function skip(token: Token.Token): (boolean)
	return token.kind == Token.fromType.Comment or token.kind == Token.fromType.NewLine
end

function Parser:next(): (Token.Token)
	self.previous = self:at()
	self.index += 1
	local token = self:at()

	while skip(token) do
		self.index += 1
		token = self:at()
	end

	return token
end

function Parser:expect(expects: Token.TokenKind): (Token.Token)
	local previous = self:eat()

	if previous.kind ~= expects then
		error(`Expected token {Token.fromKind[expects]} got {Token.fromKind[previous.kind]}`)
	end

	return previous
end

function Parser:eat(): (Token.Token)
	local previous = self:at()
	self:next()
	return previous
end

function Parser:at(): (Token.Token)
	return self.tokens[self.index]
end

function Parser:peer(): (Token.Token)
	local index = self.index
	index += 1
	local token = self.tokens[index]

	while skip(token) do
		index += 1
		token = self.tokens[index]
	end

	return token
end

function Parser:ParseArguments(): ({AST.Statement})
	self:expect(Token.fromType.OpenParenthesis)

	local arguments = {}

	--TODO: fml
	if self:at().kind ~= Token.fromType.CloseParenthesis then
		local stopped = false
		repeat
			stopped = true
			table.insert(arguments, self:ParseExpression())
			if self:at().kind == Token.fromType.Comma then stopped = false; self:eat() end
		until stopped
	end

	self:expect(Token.fromType.CloseParenthesis)
	return arguments
end

function Parser:ParseBlock(): ({AST.Statement}, number)
	local body: {AST.Statement} = {}
	self:expect(Token.fromType.OpenBrace)

	while self:at().kind ~= Token.fromType.CloseBrace do
		local statement = self:ParseStatement()
		table.insert(body, statement)
	end

	local finish = self:expect(Token.fromType.CloseBrace).range[2]
	return body, finish
end

function Parser:ParseStatement(fails: boolean?): (AST.Statement)
	if self:at().kind == Token.fromType.Identifier then
		if self:peer().kind == Token.fromType.Assign then
			return Statements:VariableAssignment(self)
		elseif self:peer().kind == Token.fromType.CompoundAssign then
			return Statements:VariableCompoundAssignment(self)
		end
	elseif self:at().kind == Token.fromType.Local or self:at().kind == Token.fromType.Global then
		if self:peer().kind == Token.fromType.Function then
			return Statements:FunctionDeclaration(self)
		else
			return Statements:VariableDeclaration(self)
		end
	elseif self:at().kind == Token.fromType.While then
		return Statements:WhileStatement(self)
	elseif self:at().kind == Token.fromType.If then
		return Statements:IfStatement(self)
	elseif self:at().kind == Token.fromType.Break then
		return {
			kind = AST.fromType.BreakStatement,
			range = self:eat().range,
		} :: AST.BreakStatement
	elseif self:at().kind == Token.fromType.Continue then
		return {
			kind = AST.fromType.ContinueStatement,
			range = self:eat().range,
		} :: AST.BreakStatement
	elseif self:at().kind == Token.fromType.Try then
		return Statements:TryStatement(self)
	end

	if fails then error(`i love oranges`) end
	return self:ParseExpression()
end

function Parser:ParseExpression(): (AST.Statement)
	return Expressions:BooleanComparisonExpression(self)
end

function Parser.new(tokens: {Token.Token}): (Parser)
	local object =  setmetatable({
		tokens = tokens or {},
		index = 1,
		previous = nil,
	}, Parser) :: any

	if not Statements then
		Statements = require("@self/Statements") :: any
	end

	if not Expressions then
		Expressions = require("@self/Expressions") :: any
	end

	return object
end

function Parser.parse(tokens: {Token.Token}): (AST.Program)
	local object = Parser.new(tokens)

	local program = {
		kind = AST.fromType.Program,
		body = {},
	} :: AST.Program

	while object:notEoF() do
		table.insert(program.body, object:ParseStatement())
	end

	if #program.body == 0 then
		 -- EoF: {1, source:len()} Range
		program.range = tokens[#tokens].range
	else
		program.range = {program.body[1].range[1], program.body[#program.body].range[2]}
	end

	return program
end

return Parser