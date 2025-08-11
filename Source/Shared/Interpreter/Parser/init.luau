--!strict
--!optimize 2

local AST = require("../Utils/AST")
local Token = require("../Utils/Token")

local Parser = {}
export type Parser = typeof(setmetatable({} :: {
	__index: Parser,

	tokens: {Token.Token},
	index: number,

	parse: (tokens: {Token.Token}) -> (AST.Program)
}, Parser))
Parser.__index = Parser

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
		kind = "Program",
		body = {},
	} :: AST.Program

	return program
end

return Parser