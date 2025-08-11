--!strict
--!optimize 2

export type NodeKind = number
export type NodeType =
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
	| "ObjectLiteral"
	| "ArrayLiteral"
	| "Identifier"
	| "Property"

export type Statement = {
	kind: NodeType
}

export type Expression = {} & Statement

export type Literal = {
	value: any?
} & Expression