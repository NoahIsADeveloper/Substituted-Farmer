--!strict
--!optimize 2

local AST = require("./AST")

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

export type ObjectValue = {
	value: {[Value]: Value},
} & Value

export type NativeFunctionValue = {
	value: (data: any, parameters: {Value}) -> (...any),
} & Value

export type FunctionValue = {
	value: {AST.Statement},
	parameters: {string},
} & Value

local ValueKindsArray = {
	"NoneValue",
	"NumberValue",
	"StringValue",
	"BooleanValue",
	"ArrayValue",
	"ObjectValue",
	"NativeFunctionValue",
	"FunctionValue",
} :: {[ValueKind]: ValueType}

local FromType = {} :: {[ValueType]: ValueKind}
local FromKind = {} :: {[ValueKind]: ValueType}

for index: ValueKind, value: any in pairs(ValueKindsArray) do
	FromType[value] = index
	FromKind[index] = value
end

local Runtime = {
	fromType = FromType,
	fromKind = FromKind,
}

function Runtime:None(): (NoneValue)
	return {
		kind = FromType.NoneValue,
		value = nil,
	}
end

function Runtime:Number(value: number): (NumberValue)
	return {
		kind = FromType.NumberValue,
		value = value,
	}
end

function Runtime:String(value: string): (StringValue)
	return {
		kind = FromType.StringValue,
		value = value,
	}
end

function Runtime:Boolean(value: boolean): (BooleanValue)
	return {
		kind = FromType.BooleanValue,
		value = value,
	}
end

function Runtime:Array(value: {any}): (ArrayValue)
	if not Evaluation then Evaluation = require("../Evaluation") :: any end
	local computedValues = {}

	for _, value in ipairs(value) do
		table.insert(computedValues, Evaluation.evaluate(value))
	end

	return {
		kind = FromType.ArrayValue,
		value = computedValues,
	}
end

function Runtime:Object(value: {[any]: any}): (ObjectValue)
	local result = {
		kind = FromType.ObjectValue,
		value = {}
	}

	for index, value in pairs(value) do
		result.value[index] = value
	end

	return result
end

function Runtime:NativeFunction(value: (scope: any, arguments: {Value}) -> (...any)): (NativeFunctionValue)
	return {
		kind = FromType.NativeFunctionValue,
		value = value,
	}
end

function Runtime:Function(value: {AST.Statement}, parameters: {string}): (NativeFunctionValue)
	return {
		kind = FromType.FunctionValue,
		value = value :: any,
		parameters = parameters,
	}
end

return Runtime