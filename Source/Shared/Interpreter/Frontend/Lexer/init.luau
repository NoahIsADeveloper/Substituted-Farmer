--!strict
--!optimize 2

local Token = require("@self/Token")

local function numeric(value: string): (boolean)
	--note! Might not work!
	return value:match("^[0-9]+$") ~= nil
end

local function alpha(value: string): (boolean)
	--note! Might not work!
	return value:match("^[A-Za-z_]+$") ~= nil
end

local function alphaNumeric(value: string): (boolean)
	--note! Might not work!
	return value:match("^[A-Za-z0-9_]+$") ~= nil
end

local function whitespace(value: string): (boolean)
	--note! I FORGOT REGEX!
	return value:match("regex") ~= nil
end

local Lexer = {}

function Lexer.tokenize(source: string): {Token.Token}
	local tokens = {} :: {Token.Token}

	--note! i did it in such a smart way before but i forgot it
	--		and the way to check it is blocked :/

	return tokens
end

return Lexer