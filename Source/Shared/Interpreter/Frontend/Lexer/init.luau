--!strict
--!optimize 2

local Token = require("@self/Token")

local function numeric(value: string): (boolean)
	return value:match("^[0-9]+$") ~= nil
end

local function alpha(value: string): (boolean)
	return value:match("^[A-Za-z_]+$") ~= nil
end

local function alphaNumeric(value: string): (boolean)
	return value:match("^[A-Za-z0-9_]+$") ~= nil
end

local function whitespace(value: string): (boolean)
	return value:match("^%s+$") ~= nil
end

local Lexer = {}

function Lexer.tokenize(source: string): {Token.Token}
	local tokens = {} :: {Token.Token}

	--note! i did it in such a smart way before but i forgot how
	--		and i can't check it cuz it's blocked :/

	return tokens
end

return Lexer