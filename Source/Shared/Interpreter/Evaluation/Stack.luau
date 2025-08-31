--!strict
--!optimize 2

local AST = require("../Utils/AST")

export type Frame = {
	kind: AST.NodeKind,
	node: AST.Statement,
	range: {number}?,
}

local Stack = {} :: Stack
Stack.__index = Stack
export type Stack = typeof(setmetatable({} :: {
	__index: Stack,

	stack: {Frame},

	Push: (self: Stack, node: AST.Statement) -> (),
	Pop: (self: Stack) -> (),
	Peek: (self: Stack) -> (Frame?),
	Depth: (self: Stack) -> (number),
	CloneStack: (self: Stack) -> ({Frame}),
	Out: (self: Stack, message: string) -> (string),

	new: () -> (Stack)
}, Stack))

function Stack:Push(node: AST.Statement): ()
	table.insert(self.stack, {
		kind = node.kind,
		node = node,
		range = node.range,
	} :: Frame)
end

function Stack:Pop(): ()
	if #self.stack == 0 then
		return nil
	end
	table.remove(self.stack)
end

function Stack:Peek(): (Frame?)
	return self.stack[#self.stack]
end

function Stack:Depth(): (number)
	return #self.stack
end

function Stack:CloneStack(): ({Frame})
	return table.clone(self.stack)
end

function Stack:Out(message: any): (string)
	local lines = { "Runtime error: " .. tostring(message), "Custom Traceback (most recent call last):" }

	for i = #self.stack, 1, -1 do
		local f = self.stack[i]
		local range = f.range and string.format("[%d, %d]", f.range[1], f.range[2]) or "[unknown]"
		table.insert(lines, ("  %s %s"):format(AST.fromKind[f.kind], range))
	end

	return table.concat(lines, "\n")
end

function Stack.new(): (Stack)
	local object = setmetatable({
		stack = {},
	}, Stack) :: any

	return object
end

return Stack