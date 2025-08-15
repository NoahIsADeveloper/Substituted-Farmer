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

	ParseStatement: (self: Parser, fails: boolean?) -> (AST.Statement),
	ParseExpression: (self: Parser) -> (AST.Statement),
	notEoF: (self: Parser) -> (boolean),
	expect: (self: Parser, expects: Token.TokenKind) -> (Token.Token),
	next: (self: Parser) -> (Token.Token),
	at: (self: Parser) -> (Token.Token),
	after: (self: Parser) -> (Token.Token),
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

function Parser:after(): (Token.Token)
	local index = self.index
	index += 1
	local token = self.tokens[index]

	while skip(token) do
		index += 1
		token = self.tokens[index]
	end

	return token
end

function Parser:ParseStatement(fails: boolean?): (AST.Statement)
	if self:at().kind == Token.fromType.Identifier then
		if self:after().kind == Token.fromType.Assign then
			return Statements:VariableAssignment(self)
		elseif self:after().kind == Token.fromType.CompoundAssign then
			return Statements:VariableCompoundAssignment(self)
		end
	elseif self:at().kind == Token.fromType.Local or self:at().kind == Token.fromType.Global then
		return Statements:VariableDeclaration(self)
	elseif self:at().kind == Token.fromType.While then
		return Statements:WhileStatement(self)
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

	program.range = {program.body[1].range[1], program.body[#program.body].range[2]}
	return program
end

return Parser