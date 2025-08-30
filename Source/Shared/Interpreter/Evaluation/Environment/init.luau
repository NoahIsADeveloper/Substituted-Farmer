--!strict
--!optimize 2

local Values = require("../Utils/Runtime")
local AST = require("../Utils/AST")

local Environment = {} :: Environment
export type Environment = typeof(setmetatable({} :: {
	__index: Environment,

	parent: Environment?,
	variables: {[string]: any},
	constants: {string},

	DeclareVariable: (self: Environment, name: string, value: Values.Value, constant: boolean) -> (),
	AssignVariable: (self: Environment, name: string, value: Values.Value) -> (),
	LookupVariable: (self: Environment, name: string) -> (Values.Value),
	DeclareGlobals: (self: Environment) -> (),
	Resolve: (self: Environment, name: string?) -> (Environment),

	new: (parent: Environment?) -> (Environment),
}, Environment))
Environment.__index = Environment

function Environment:DeclareVariable(name: string, value: Values.Value, immutable: boolean): ()
	if not name then error(`Cannot declare variable without a name`) end
	if self.variables[name] then error(`Cannot declare variable '{name}' as it already exists`) end

	self.variables[name] = value
	if immutable then table.insert(self.constants, name) end
end

function Environment:AssignVariable(name: string, value: Values.Value): ()
	local environment = self:Resolve(name)

	--TODO: better error text
	if not environment then error(`ts shldnt b posble 🥀`) end
	if table.find(environment.constants, name) then error(`Cannot reassign variable '{name}' it is immutable.`) end
	if not environment.variables[name] then error(`Cannot assign variable '{name}' it does not exist`) end

	environment.variables[name] = value
end

function Environment:LookupVariable(name: string): (Values.Value)
	local environment = self:Resolve(name)

	--TODO: better error text
	if not environment then error(`wtaf is ts 🪦`) end

	return environment.variables[name] or Values:None()
end

function Environment:Resolve(name: string?): (Environment)
	if name and self.variables[name] then return self end
	if not self.parent then return self end
	return self.parent:Resolve(name)
end

function Environment:DeclareGlobals(): ()
	self:DeclareVariable("print", Values:NativeFunction(function(scope: Environment, arguments: {Values.Value})
		print(arguments)
	end), true)
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