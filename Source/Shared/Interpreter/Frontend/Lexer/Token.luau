--!strict
--!optimize 2

export type Token = {
	value: string,
	raw: string,
	kind: number,
	range: {number},
}

local TokenKinds = {
	-- // Literal types
	Number = 1,
	Identifier = 2,
	String = 3,

	-- // Other
	Operator = 4,
	Grouping = 5,
	Keyword = 6,
	Comment = 7,

	EndOfFile = 8,
	NewLine = 9,
}

local TokenCharacters = {
	-- // Grouping
	["("] = TokenKinds.Grouping,
	[")"] = TokenKinds.Grouping,
	["["] = TokenKinds.Grouping,
	["]"] = TokenKinds.Grouping,
	["{"] = TokenKinds.Grouping,
	["}"] = TokenKinds.Grouping,
	[","] = TokenKinds.Grouping,
	["|"] = TokenKinds.Comment,

	-- // Operators
	["+"] = TokenKinds.Operator,
	["-"] = TokenKinds.Operator,
	["/"] = TokenKinds.Operator,
	["*"] = TokenKinds.Operator,
	["%"] = TokenKinds.Operator,
	["^"] = TokenKinds.Operator,

	["<"] = TokenKinds.Operator,
	[">"] = TokenKinds.Operator,
	["!"] = TokenKinds.Operator,	-- Unary
	[":"] = TokenKinds.Operator,
	["."] = TokenKinds.Operator,

	-- // Other
	["\n"] = TokenKinds.NewLine,
}

local ReverseLookup = {}
for index, value in pairs(TokenCharacters) do
	ReverseLookup[value] = index
end

return {
	new = function(value: string, kind: number, raw: string, start: number, finish: number): (Token)
		return {
			value = value,
			raw = raw,
			kind = kind,
			range = {start, finish},
		}
	end,
	kinds = {
		to = TokenKinds,
		from = ReverseLookup,
	},
	fromCharacter = TokenCharacters,
}
