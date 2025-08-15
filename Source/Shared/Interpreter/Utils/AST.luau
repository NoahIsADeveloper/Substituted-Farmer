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
	| "Identifier"
	| "Property"

local NodeKindsArray = {
	"Program", "VariableDeclaration", "VariableAssignment",
	"FunctionDeclaration", "IfStatement", "ForStatement",
	"TryStatement", "ReturnStatement", "ContinueStatement",
	"BreakStatement", "ImportStatement",

	"BinaryExpression", "BooleanExpression",
	"CallExpression", "MemberExpression",

	"BooleanLiteral", "NumericLiteral", "StringLiteral",
	"NoneLiteral", "ObjectLiteral", "ArrayLiteral",
	"Identifier", "Property",
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
	parameters: {Identifier},
	body: {Statement},
	name: Identifier?,
} & Statement

export type IfStatement = {
	condition: Expression,
	alternate: {Statement}?,
	body: {Statement},
	name: Identifier,
} & Statement

export type TryStatement = {
	alternate: {Statement}?,
	body: {Statement},
	symbol: Identifier,
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
	arguments: {Identifier},
	caller: FunctionDeclaration,
} & Expression

export type MemberExpression = {
	property: Identifier | Expression,
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

export type Identifier = {
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