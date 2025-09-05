--!strict
--!optimize 2

local Library = require("../")
local Runtime = require("../../Runtime")

return {
	name = "Example Library",
	symbol = "example",
	version = "v1.0.0",
	author = "NoahIsADeveloper",
	tree = Runtime:Object({
		hello = Runtime:String("Hello!"),
		goodbye = Runtime:String("Goodbye!"),
	})
} :: Library.Library