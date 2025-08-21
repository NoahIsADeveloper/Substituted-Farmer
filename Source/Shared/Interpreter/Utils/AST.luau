--!strict
--!optimize 2

export type NodeKind = number
export type NodeType =
	| string

	-- // Statements
	| "Program"
	| "VariableDeclaration"
	| "VariableAssignment"
	| "FunctionDeclaration"
	| "IfStatement"
	| "ForStatement"
	| "WhileStatement"
	| "TryStatement"
	| "ReturnStatement"
	| "ContinueStatement"
	| "BreakStatement"
	| "ImportStatement"

	-- // Expressions
	| "BinaryExpression"
	| "BooleanExpression"
	| "CallExpression"
	| "MemberExpression"

	-- // Literals
	| "BooleanLiteral"
	| "NumericLiteral"
	| "StringLiteral"
	| "NoneLiteral"
	| "ObjectLiteral"
	| "ArrayLiteral"
	| "FunctionLiteral"
	| "IdentifierLiteral"
	| "Property"

local NodeKindsArray = {
	"Program", "VariableDeclaration", "VariableAssignment",
	"FunctionDeclaration", "IfStatement", "ForStatement",
	"WhileStatement", "TryStatement", "ReturnStatement",
	"ContinueStatement", "BreakStatement", "ImportStatement",

	"BinaryExpression", "BooleanExpression", "CallExpression",
	"MemberExpression",

	"BooleanLiteral", "NumericLiteral", "StringLiteral",
	"NoneLiteral", "ObjectLiteral", "ArrayLiteral",
	"FunctionLiteral", "IdentifierLiteral", "Property",
} :: {[NodeKind]: NodeType}

local FromType = {} :: {[NodeType]: NodeKind}
local FromKind = {} :: {[NodeKind]: NodeType}

for index: NodeKind, value: any in pairs(NodeKindsArray) do
	FromType[value] = index
	FromKind[index] = value
end

export type Statement = {
	kind: NodeKind,
	range: {number},
}

export type Program = {
	body: {Statement},
} & Statement

export type VariableDeclaration = {
	immutable: boolean,
	global: boolean,
	identifier: string,
	value: Expression?,
} & Statement

export type VariableAssignment = {
	identifier: string,
	value: Expression,
} & Statement

export type FunctionDeclaration = {
	parameters: {IdentifierLiteral},
	body: {Statement},
	name: string,
} & Statement

export type IfStatement = {
	condition: Expression,
	alternate: {Statement}?,
	body: {Statement},
} & Statement

--TODO: needs data
export type ForStatement = {

} & Statement

export type WhileStatement = {
	condition: Expression,
	alternate: {Statement}?,
	body: {Statement},
} & Statement

export type TryStatement = {
	alternate: {Statement}?,
	body: {Statement},
	symbol: IdentifierLiteral,
} & Statement

export type ReturnStatement = {
	arguments: {Expression}?,
} & Statement

export type ContinueStatement = {

} & Statement

export type BreakStatement = {

} & Statement

export type Expression = {} & Statement

export type BinaryExpression = {
	left: Expression,
	right: Expression,
	operator: string,
} & Expression

export type BooleanExpression = {
	left: Expression,
	right: Expression,
	operator: string,
} & Expression

export type CallExpression = {
	arguments: {IdentifierLiteral},
	caller: Expression, --TODO: is this accurate?
} & Expression

export type MemberExpression = {
	property: IdentifierLiteral | Expression,
	object: ObjectLiteral,
	computed: boolean,
} & Expression

export type Literal = { value: any } & Expression
export type NoneLiteral = {} & Literal

export type BooleanLiteral = {
	value: boolean,
} & Literal

export type NumericLiteral = {
	value: number,
} & Literal

export type StringLiteral = {
	value: string,
} & Literal

export type ObjectLiteral = {
	value: {Property},
} & Literal

export type ArrayLiteral = {
	value: {Statement},
} & Literal

export type FunctionLiteral = {
	value: {Statement},
} & Literal

export type IdentifierLiteral = {
	value: string,
} & Literal

export type Property = {
	value: Expression?,
	key: any,
} & Literal

local Module = {
	fromType = FromType,
	fromKind = FromKind,
}

return Module