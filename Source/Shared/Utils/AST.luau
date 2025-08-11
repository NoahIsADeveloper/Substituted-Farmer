--!strict
--!optimize 2

export type NodeKind = number
export type NodeType =
	| string

	-- // Statements
	| "Program"
	| "VariableDeclaration"
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
	| "AssignmentExpression"
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
	"Program", "VariableDeclaration", "FunctionDeclaration",
	"IfStatement", "ForStatement", "TryStatement",
	"ReturnStatement", "ContinueStatement", "BreakStatement",
	"ImportStatement",

	"BinaryExpression", "AssignmentExpression", "CallExpression",
	"MemberExpression",

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

export type Expression = {} & Statement

export type Literal = {
	value: any,
} & Expression

local Module = {
	fromType = FromType,
	fromKind = FromKind,
}

return Module