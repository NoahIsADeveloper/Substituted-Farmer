--!strict
--!optimize 2

return {
	["name"] = "English",
	["code"] = "en",

	["lookup.operators"] = {
		["+"] = "addition",
		["-"] = "subtraction",
		["/"] = "division",
		["*"] = "multiplication",
		["%"] = "modulus",
		["^"] = "exponentiation"
	},

	["values.NoneValue"] = "none",
	["values.NumberValue"] = "number",
	["values.StringValue"] = "string",
	["values.BooleanValue"] = "boolean",
	["values.ArrayValue"] = "array",
	["values.ObjectValue"] = "object",
	["values.NativeFunctionValue"] = "native function",
	["values.FunctionValue"] = "function",

	["ast.Program"] = "Program",
	["ast.VariableDeclaration"] = "Variable Declaration",
	["ast.VariableAssignment"] = "Variable Assignment",
	["ast.FunctionDeclaration"] = "Function Declaration",
	["ast.IfStatement"] = "If Statement",
	["ast.ForStatement"] = "For Statement",
	["ast.WhileStatement"] = "While Statement",
	["ast.TryStatement"] = "Try Statement",
	["ast.ReturnStatement"] = "Return Statement",
	["ast.ContinueStatement"] = "Continue Statement",
	["ast.BreakStatement"] = "Break Statement",
	["ast.ImportStatement"] = "Import Statement",
	["ast.BinaryExpression"] = "Arithmetic Expression",
	["ast.BooleanExpression"] = "Logical Expression",
	["ast.CallExpression"] = "Call Expression",
	["ast.MemberExpression"] = "Member Expression",
	["ast.BooleanLiteral"] = "boolean",
	["ast.NumericLiteral"] = "number",
	["ast.StringLiteral"] = "string",
	["ast.NoneLiteral"] = "none",
	["ast.ObjectLiteral"] = "object",
	["ast.ArrayLiteral"] = "array",
	["ast.FunctionLiteral"] = "function",
	["ast.IdentifierLiteral"] = "identifier",
	["ast.Property"] = "property",

	["error.evaluation.missing"] = "Cannot evaluate node '%s' as it has not been set up yet.",									-- Node Name
	["error.evaluation.binaryexprinvalidoperator"] = "Operator '%s' is not a valid operator",									-- Raw operator
	["error.evaluation.binaryexprinvalidoperation"] = "Cannot compute %s expression on %s and %s",								-- Operator, Left, Right
	["error.evaluation.boolexprinvalidoperator"] = "Boolean operator '%s' is not a valid operator",								-- Raw operator
	["error.evaluation.invalidcall"] = "Value '%s' is not callable",															-- Value Type

}