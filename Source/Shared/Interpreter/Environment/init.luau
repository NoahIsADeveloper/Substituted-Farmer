--!strict
--!optimize 2

local Runtime = require("./Utils/Runtime")

local Environment = {} :: Environment
export type Environment = typeof(setmetatable({} :: {
	__index: Environment,

	variables: {[string]: any},
	constants: {string},

	DeclareVariable: (self: Environment, name: string, value: Runtime.Value, constant: boolean) -> (),
	AssignVariable: (self: Environment, name: string, value: Runtime.Value) -> (),
	LookupVariable: (slf: Environment, name: string) -> (Runtime.Value),

	new: (parent: Environment?) -> (Environment),
}, Environment))
Environment.__index = Environment

function Environment:DeclareVariable(name: string, value: Runtime.Value, immutable: boolean): ()
	if self.variables[name] then error(`Cannot declare variable '{name}' as it already exists`) end

	self.variables[name] = value
	if immutable then table.insert(self.constants, name) end
end

function Environment:AssignVariable(name: string, value: Runtime.Value): ()
	if table.find(self.constants, name) then error(`Cannot assign variable '{name}' to {value.value} as it is immutable.`) end
	if not self.variables[name] then error(`Cannot assign variable '{name}' to {value.value} as '{name}' does not exist`) end
end

function Environment.new(parent: Environment?): (Environment)
	local object = setmetatable({
		parent = parent,
		variables = {},
		constants = {},
	}, Environment) :: any

	return object
end

return Environment