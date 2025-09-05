--!strict
--!optimize 2

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Runtime = require("./Runtime")

local Cache = {} :: {[string]: Runtime.Value}
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

local BuiltIn = script:FindFirstChild("BuiltIn")

function Libraries:Get(name: string): (Runtime.Value, Library?)
	name = name:lower()

	if Cache[name] then return Cache[name] end
	local moduleScript = BuiltIn:FindFirstChild(name)
	local lookup = Lookup[name]

	if lookup then
		if RunService:IsServer() then
			local library = HttpService:GetAsync(lookup, true)
			if not library then return Runtime:None() end
			local result = HttpService:JSONDecode(library) :: Library

			return result.tree, library
		else
			--TODO: ask the server for the library instead
		end
	elseif moduleScript and moduleScript:IsA("ModuleScript") then
		--TODO: error safety
		local result = require(moduleScript) :: any
		Cache[name] = result.tree
		return result.tree, result
	end

	return Runtime:None()
end

return Libraries