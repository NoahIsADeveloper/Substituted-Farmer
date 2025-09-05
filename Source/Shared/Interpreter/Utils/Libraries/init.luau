--!strict
--!optimize 2

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Runtime = require("./Runtime")

local Cache = {} :: {[string]: Library}
local Libraries = {}

local Lookup = {
	["example-remote"] = "https://raw.githubusercontent.com/NoahIsADeveloper/Substituted-Farmer/refs/heads/main/Source/Shared/Interpreter/Utils/Libraries/Example.json"
} :: {[string]: string}
export type Library = {
	name: string,
	symbol: string,
	author: string,
	version: string,
	tree: Runtime.Value,
}

local RemoteFunction = script:FindFirstChild("RemoteFunction") :: RemoteFunction
local BuiltIn = script:FindFirstChild("BuiltIn")

function Libraries:Get(name: string): (Runtime.Value, Library?)
	name = name:lower()

	if Cache[name] then return Cache[name].tree, Cache[name] end
	local moduleScript = BuiltIn:FindFirstChild(name)
	local lookup = Lookup[name]

	if lookup then
		local library = if RunService:IsServer() then HttpService:GetAsync(lookup, true) else RemoteFunction:InvokeServer(name)
		if not library then return Runtime:None() end
		local result = HttpService:JSONDecode(library) :: Library

		Cache[name] = result
		return result.tree, result
	elseif moduleScript and moduleScript:IsA("ModuleScript") then
		--TODO: error safety
		local result = require(moduleScript) :: any
		Cache[name] = result
		return result.tree, result
	end

	return Runtime:None()
end

function Libraries.init()
	if RunService:IsClient() then return end

	function RemoteFunction.OnServerInvoke(player, name: string): (Library?)
		local lookup = Lookup[name]
		if not lookup then return nil end

		return HttpService:GetAsync(lookup, true)
	end
end

return Libraries