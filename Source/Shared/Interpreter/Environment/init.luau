--!strict
--!optimize 2

local Environment = {} :: Environment
export type Environment = typeof(setmetatable({} :: {
	__index: Environment,

	variables: {[string]: any},
	constants: {string},

	new: (parent: Environment?) -> (Environment),
}, Environment))
Environment.__index = Environment

function Environment.new(parent: Environment?): (Environment)
	local object = setmetatable({
		parent = parent,
		variables = {},
		constants = {},
	}, Environment) :: any

	return object
end

return Environment