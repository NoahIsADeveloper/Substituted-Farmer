--!strict
--!optimize 2

local AST = require("./Utils/AST")
local Token = require("./Utils/Token")
local Statements
if not Statements then
	Statements = require("@self/Statements") :: any
end

local Parser = {} :: Parser
export type Parser = typeof(setmetatable({} :: {
	__index: Parser,

	tokens: {Token.Token},
	index: number,

	ParseStatement: (self: Parser) -> (AST.Statement),
	notEoF: (self: Parser) -> (boolean),
	expect: (self: Parser, expects: Token.TokenKind) -> (Token.Token),
	next: (self: Parser) -> (Token.Token),
	at: (self: Parser) -> (Token.Token),
	eat: (self: Parser) -> (Token.Token),

	new: (tokens: {Token.Token}) -> (Parser),
	parse: (tokens: {Token.Token}) -> (AST.Program),
}, Parser))
Parser.__index = Parser

function Parser:notEoF(): (boolean)
	return self:at().kind == Token.fromType.EoF
end

function Parser:next(): (Token.Token)
	self.index += 1
	local token = self:at()

	while
		token.kind == Token.fromType.Comment or
		token.kind == Token.fromType.NewLine
	do
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

function Parser:ParseStatement(): (AST.Statement)
	if
		self:at().kind == Token.fromType.Local or
		self:at().kind == Token.fromType.Global
	then
		Statements:VariableDeclaration(self)
	end

	return nil :: any
end

function Parser.new(tokens: {Token.Token}): (Parser)
	local object =  setmetatable({
		tokens = tokens or {},
		index = 1,
	}, Parser) :: any

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

	return program
end

return Parser