--!strict
--!optimize 2

local AST = require("../../Utils/AST")
local Token = require("../../Utils/Token")

local Parser = {}
export type Parser = typeof(setmetatable({} :: {
	__index: Parser,

	tokens: {Token.Token},
	index: number,

	parse: (tokens: {Token.Token}) -> (AST.Program)
}, Parser))
Parser.__index = Parser

function Parser.parse(tokens)
	local object =  setmetatable({
		tokens = tokens,
		index = 1,
	}, Parser)

	local program = {
		kind = "Program",
		body = {}
	} :: AST.Program

	-- while not eof do
	-- 	table.insert(program.body, object:ParseStatement())
	-- end

	return program
end

return Parser