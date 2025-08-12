--!strict
--!optimize 2

export type ValueKind = number
export type ValueType =
	-- // Literals
	| "NoneValue"
	| "NumberValue"
	| "StringValue"
	| "BooleanValue"
	| "ArrayValue"
	| "ObjectValue"

	-- // Functions
	| "NativeFunctionValue"
	| "FunctionValue"

export type Value = {
	kind: ValueKind,
	value: any,
}

export type NoneValue = {
	value: nil,
} & Value

export type NumberValue = {
	value: number,
} & Value

export type StringValue = {
	value: string,
} & Value

export type BooleanValue = {
	value: boolean,
} & Value

local ValueKindsArray = {
	"NoneValue", "NumberValue", "StringValue",
	"BooleanValue", "ArrayValue", "ObjectValue",
	"NativeFunctionValue", "FunctionValue",
} :: {[ValueKind]: ValueType}

local FromType = {} :: {[ValueType]: ValueKind}
local FromKind = {} :: {[ValueKind]: ValueType}

for index: ValueKind, value: any in pairs(ValueKindsArray) do
	FromType[value] = index
	FromKind[index] = value
end

local Module = {
	fromType = FromType,
	fromKind = FromKind,
}

return Module