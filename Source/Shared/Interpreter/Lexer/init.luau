--!strict
--!optimize 2

local Token = require("./Utils/Token")

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
		local previous = at()
		index += 1
		return previous
	end

	local function shiftUntilInterupt(interupt: (at: string, last: string) -> boolean): (string, number, number)
		local start = index
		local value = ""
		local last = ""

		while index <= source:len() and not interupt(at(), last) do
			last = eat()
			value ..= last
		end

		return value, start, index - 1
	end

	local function addToken(kind: number, raw: string, value: any, start: number, finish: number)
		table.insert(tokens, Token.new(kind, raw, value, start, finish))
	end

	while source:len() > index do
		local character = at()

		local start = index
		local tokenKind = Token.fromCharacter[character]

		if not tokenKind and whitespace(character) then eat(); continue end

		-- // Single character
		if tokenKind then
			eat()
			--TODO: whoever wrote this should die in rouge lineage
			if
				tokenKind ~= Token.fromType.Quote and		-- Strings
				tokenKind ~= Token.fromType.Comment and		-- Comments
				not (
					(
						tokenKind == Token.fromType.BinaryOperator or	-- Compound assign
						tokenKind == Token.fromType.Compare or			-- Comparisons (>= <=)
						tokenKind == Token.fromType.Assign or			-- ==
						tokenKind == Token.fromType.Unary				-- !=
					) and
					Token.fromCharacter[at()] == Token.fromType.Assign
				)
			then
				addToken(tokenKind, character, character, start, start)
				continue
			end
		end

		-- // Multi character
		if tokenKind == Token.fromType.BinaryOperator then
			addToken(Token.fromType.CompoundAssign, `{character}{eat()}`, `{character}{eat()}`, start, index - 1)
		elseif tokenKind == Token.fromType.Compare or tokenKind == Token.fromType.Unary or tokenKind == Token.fromType.Assign then
			addToken(Token.fromType.Compare, `{character}{eat()}`, `{character}{eat()}`, start, index - 1)
		elseif tokenKind == Token.fromType.Quote then
			--TODO: better escape characters
			local value, _, finishIndex = shiftUntilInterupt(function(value, last)
				return value == character and last ~= "\\"
			end)
			-- fuck you it works
			addToken(Token.fromType.String, `{character}{value}{character}`, value, start, finishIndex + 1)
			eat()
		elseif tokenKind == Token.fromType.Comment then
			local value, _, finishIndex = shiftUntilInterupt(function(value)
				return value == character
			end)

			-- fuck you it works (x2)
			addToken(Token.fromType.Comment, `{character}{value}{character}`, value, start, finishIndex + 1)
			eat()
		elseif numeric(character) then
			--TODO: kill yourself
			local decimals = false
			local value, startIndex, finishIndex = shiftUntilInterupt(function(value)
				if value == "." then
					if decimals then
						return true
					else
						decimals = true
					end
				end

				return not numeric(value) and value ~= "."
			end)
			local result = tonumber(value) :: number
			--TODO: better error handling
			if not result then error(`Malformed number`) end
			addToken(Token.fromType.Number, value, result, startIndex, finishIndex)
		elseif alpha(character) then
			local value, startIndex, finishIndex = shiftUntilInterupt(function(value)
				return not alphaNumeric(value)
			end)

			addToken(Token.fromType.Identifier, value, value, startIndex, finishIndex)
		end
	end

	addToken(Token.fromType.EoF, "", nil, 1, source:len())

	return tokens
end

return Lexer