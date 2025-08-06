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

function Lexer.tokenize(source: string): ({Token.Token})
	local tokens = {} :: {Token.Token}
	local index = 1

	local function at(): string
		return source:sub(index, index)
	end

	local function eat(): string
		local previous = source:sub(index, index)
		index += 1
		return previous
	end

	local function shiftUntilInterupt(interupt: (at: string, last: string) -> boolean): string
		local start = index
		local value = ""
		local last = ""

		while index <= source:len() and not interupt(at(), last) do
			last = eat()
			value ..= last
		end

		return value, start, index - 1
	end

	while source:len() > index do
		local character = at()

		local start = index
		local tokenType = Token.fromCharacter[character]

		if not tokenType and whitespace(character) then eat(); continue end
	end

	return tokens
end

return Lexer