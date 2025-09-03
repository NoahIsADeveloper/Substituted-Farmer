--!strict
--!optimize 2

local AST = require("../Utils/AST")

export type Frame = {
	kind: AST.NodeKind,
	node: AST.Statement,
	range: {number}?,
	name: string?,
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
	Out: (self: Stack, message: string, location: {number}, name: string) -> (string),

	new: () -> (Stack)
}, Stack))

function Stack:Push(node: AST.Statement, name: string?): ()
	table.insert(self.stack, {
		kind = node.kind,
		node = node,
		range = node.range,
		name = name,
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

function Stack:Out(message: any, location: {number}, name: string): (string)
	local lines = { `Runtime error: {tostring(message)}`, "Traceback:" }

	if location then
		local range = if location then string.format("[%d, %d]", location[1], location[2]) else "[unknown]"
		table.insert(lines, ("\t%s %s"):format(name or "unknown", range))
	end

	for index = 1, #self.stack do
		local frame = self.stack[index]
		local range = if frame.range then string.format("[%d, %d]", frame.range[1], frame.range[2]) else "[unknown]"

		table.insert(lines, ("\t%s%s %s"):format(
			`{AST.fromKind[frame.kind]}`,
			if frame.name then` {frame.name}` else "",
			range
		))
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