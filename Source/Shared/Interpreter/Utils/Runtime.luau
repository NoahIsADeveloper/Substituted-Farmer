--!strict
--!optimize 2

local Evaluation

export type ValueKind = number
export type ValueType =
	| string

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

export type ArrayValue = {
	value: {Value},
} & Value

export type NativeFunctionValue = {
	value: (...any) -> (...any),
} & Value

-- export type FunctionValue = {
-- 	value: {AST.Statement},
-- 	parameters: {string},
-- 	environment: Environment.Environment,
-- } & Value

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

function Module:None(): (NoneValue)
	return {
		kind = FromType.NoneValue,
		value = nil,
	}
end

function Module:Number(value: number): (NumberValue)
	return {
		kind = FromType.NumberValue,
		value = value,
	}
end

function Module:String(value: string): (StringValue)
	return {
		kind = FromType.StringValue,
		value = value,
	}
end

function Module:Boolean(value: boolean): (BooleanValue)
	return {
		kind = FromType.BooleanValue,
		value = value,
	}
end

function Module:Array(value: {any}): (ArrayValue)
	Evaluation = require("../Evaluation") :: any
	local computedValues = {}

	for _, value in pairs(value) do
		table.insert(computedValues, Evaluation.evaluate(value))
	end

	return {
		kind = FromType.ArrayValue,
		value = computedValues,
	}
end

return Module