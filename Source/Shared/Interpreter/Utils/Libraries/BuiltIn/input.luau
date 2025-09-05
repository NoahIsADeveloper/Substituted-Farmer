--!strict
--!optimize 2

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = require("../")
local Runtime = require("../../Runtime")

-- so many parents...
local Evaluation = require("../../../Evaluation")
local Signal = require("../../../../Utils/Signal")

local Signals = {
	InputBegan = Signal.new(),
	InputEnded = Signal.new()
}

UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		Signals.InputBegan:Fire(Runtime:String(input.KeyCode.Name))
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject, processed: boolean)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		Signals.InputEnded:Fire(Runtime:String(input.KeyCode.Name))
	end
end)

local function handle(data, arguments: {Runtime.Value}, signal: Signal.Signal): (Runtime.Value)
	local stack = data.stack:Clone()
	--TODO: this fucking bricks the shit outta how the traceback is meant to work
	local evaluationData = {
		environment = data.environment,
		stack = stack,
	}

	if #arguments ~= 1 or arguments[1].kind ~= Runtime.fromType.FunctionValue then
		error(`expected 1 argument of type function value`)
	end

	local node = arguments[1] :: Runtime.FunctionValue

	local connection = signal:Connect(function(_, ...)
		Evaluation.up(evaluationData)

		for index, value in pairs({...}) do
			if node.parameters[index] then
				evaluationData.environment:DeclareVariable(node.parameters[index], value, false)
			end
		end

		Evaluation.evaluateBody(node.value, evaluationData)
		Evaluation.down(evaluationData)
	end)

	return Runtime:NativeFunction(function()
		connection:Disconnect()
	end)
end

return if RunService:IsClient() then
	{
		name = "Input Library",
		symbol = "input",
		version = "1.0.0",
		author = "NoahIsADeveloper",
		tree = Runtime:Object({
			inputBegan = Runtime:NativeFunction(function(data, arguments): (...any)
				handle(data, arguments, Signals.InputBegan)
			end),
			inputEnded = Runtime:NativeFunction(function(data, arguments): (...any)
				handle(data, arguments, Signals.InputEnded)
			end),
			isKeyDown = Runtime:NativeFunction(function(data, arguments)
				if #arguments ~= 1 or arguments[1].kind ~= Runtime.fromType.StringValue then
					error(`expected 1 argument of type function value`)
				end

				local enum = Enum.KeyCode:FromName(arguments[1].value)
				if not enum then return Runtime:None() end

				return UserInputService:IsKeyDown(enum)
			end)
		})
	} :: Library.Library
else Runtime:None()