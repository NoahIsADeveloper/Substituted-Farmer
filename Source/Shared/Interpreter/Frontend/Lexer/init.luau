--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Token = require(ReplicatedStorage.Shared.Utils.Token)
local Tokens = require("../../Utils/Token")

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

function Lexer.tokenize(source: string): ({Tokens.Token})
	local tokens = {} :: {Tokens.Token}
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
		table.insert(tokens, Tokens.new(kind, raw, value, start, finish))
	end

	while source:len() > index do
		local character = at()

		local start = index
		local tokenKind = Tokens.fromCharacter[character]

		if not tokenKind and whitespace(character) then eat(); continue end

		-- // Single character
		if tokenKind then
			eat()
			--TODO: whoever wrote this should die in rouge lineage
			if
				tokenKind ~= Tokens.fromType.Quote and		-- Tokenize Strings
				tokenKind ~= Tokens.fromType.Comment and	-- Tokenize Comments
				not (
					(
						tokenKind == Token.fromType.BinaryOperator or	-- Compound assign
						tokenKind == Token.fromType.Compare or			-- Comparisons (>= <=)
						tokenKind == Token.fromType.Assign or			-- ==
						tokenKind == Token.fromType.Unary				-- !=
					) and
					Tokens.fromCharacter[at()] == Token.fromType.Assign
				)
			then
				addToken(tokenKind, character, character, start, start)
				continue
			end
		end

		-- // Multi character
		if tokenKind == Tokens.fromType.BinaryOperator then
			addToken(Tokens.fromType.CompoundAssign, `{character}{eat()}`, `{character}{eat()}`, start, index - 1)
		elseif tokenKind == Tokens.fromType.Compare or tokenKind == Tokens.fromType.Unary or tokenKind == Tokens.fromType.Assign then
			addToken(Tokens.fromType.Compare, `{character}{eat()}`, `{character}{eat()}`, start, index - 1)
		elseif tokenKind == Tokens.fromType.Quote then
			local value, startIndex, finishIndex = shiftUntilInterupt(function(value, last)
				return value == character and last ~= "\\"
			end)
			--TODO: janky way to get raw string, also needs better (working) escape
			addToken(Tokens.fromType.String, `{character}{value}{character}`, value, startIndex - 1, finishIndex + 1)
			eat()
		elseif tokenKind == Tokens.fromType.Comment then
			--TODO: store the comments somewhere!
			--		parser will be cancer though
			shiftUntilInterupt(function(value)
				return value == character
			end)

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
			addToken(Tokens.fromType.Number, value, result, startIndex, finishIndex)
		elseif alpha(character) then
			local value, startIndex, finishIndex = shiftUntilInterupt(function(value)
				return not alphaNumeric(value)
			end)

			addToken(Tokens.fromType.Identifier, value, value, startIndex, finishIndex)
		end
	end

	addToken(Tokens.fromType.EoF, "", nil, 1, source:len())

	return tokens
end

return Lexer