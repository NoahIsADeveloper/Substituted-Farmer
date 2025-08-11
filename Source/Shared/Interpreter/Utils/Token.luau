--!strict
--!optimize 2

export type TokenKind = number
export type TokenType =
	| string	-- // This fucking sucks but the linter is retarded as shit and I don't want warnings
	| "EoF"
	| "NewLine"
	| "Comment"

	-- // Literal types
	| "Number"
	| "Identifier"
	| "String"
	| "Boolean"
	| "None"

	-- // Keywords
	| "Local"
	| "Global"
	| "Import"
	| "Function"
	| "If"
	| "Else"
	| "For"
	| "While"
	| "Try"
	| "Return"
	| "Break"
	| "Continue"
	| "Class"
	| "Extends"

	-- // Operators
	| "BooleanOperator"
	| "BinaryOperator"
	| "Assign"
	| "CompoundAssign"
	| "Compare"
	| "Unary"

	-- // Grouping
	| "Comma"
	| "Quote"
	| "Period"
	| "OpenParenthesis"
	| "CloseParenthesis"
	| "OpenBrace"
	| "CloseBrace"
	| "OpenBracket"
	| "CloseBracket"
	| "Semicolon"
	| "Colon"

export type Token = {
	value: any?,
	raw: string,
	kind: TokenKind,
	range: {number},
}

local TokenKindsArray = {
	"EoF", "NewLine", "Comment",

	"Number", "Identifier", "String",
	"Boolean", "Null",

	"Local", "Global", "Import", "Function",
	"If", "Else", "For",
	"While", "Try", "Return",
	"Break", "Continue", "Class",
	"Extends",

	"BooleanOperator", "BinaryOperator", "Assign",
	"CompoundAssign", "Compare", "Unary",

	"Comma", "Quote", "Period",
	"OpenParenthesis", "CloseParenthesis",
	"OpenBrace", "CloseBrace",
	"OpenBracket", "CloseBracket",
	"Semicolon", "Colon",
} :: {[TokenKind]: TokenType}

local FromType = {} :: {[TokenType]: TokenKind}
local FromKind = {} :: {[TokenKind]: TokenType}

for index: TokenKind, value: any in pairs(TokenKindsArray) do
	FromType[value] = index
	FromKind[index] = value
end

local FromCharacter = {
	["("] = FromType.OpenParenthesis,
	[")"] = FromType.CloseParenthesis,
	["{"] = FromType.OpenBrace,
	["}"] = FromType.CloseBrace,
	["["] = FromType.OpenBracket,
	["]"] = FromType.OpenBracket,
	["!"] = FromType.Unary,
	["+"] = FromType.BinaryOperator,
	["-"] = FromType.BinaryOperator,
	["*"] = FromType.BinaryOperator,
	["/"] = FromType.BinaryOperator,
	["%"] = FromType.BinaryOperator,
	["^"] = FromType.BinaryOperator,
	["<"] = FromType.Compare,
	[">"] = FromType.Compare,
	[","] = FromType.Comma,
	["."] = FromType.Period,
	["="] = FromType.Assign,
	["\""] = FromType.Quote,
	["'"] = FromType.Quote,
	["`"] = FromType.Quote,
	["|"] = FromType.Comment,
	["\n"] = FromType.NewLine,
} :: {[string]: TokenKind}

local FromKeyword = {
	["extends"] = FromType.Extends,
	["class"] = FromType.Class,
	["continue"] = FromType.Continue,
	["break"] = FromType.Break,
	["return"] = FromType.Return,
	["function"] = FromType.Function,
	["if"] = FromType.If,
	["else"] = FromType.Else,
	["for"] = FromType.For,
	["while"] = FromType.While,
	["try"] = FromType.Try,
	["and"] = FromType.BooleanOperator,
	["or"] = FromType.BooleanOperator,
	["local"] = FromType.Local,
	["global"] = FromType.Global,
	["import"] = FromType.Import,
	["true"] = FromType.Boolean,
	["false"] = FromType.Boolean,
	["null"] = FromType.None,
} :: {[string]: TokenKind}

local Module = {
	new = function(kind: TokenKind, value: string?, raw: string?, start: number, finish: number): (Token)
		return {
			kind = kind,
			value = value,
			raw = raw,
			range = {start, finish}
		} :: Token
	end,
	fromKeyword = FromKeyword,
	fromCharacter = FromCharacter,
	fromType = FromType,
	fromKind = FromKind,
}

return Module