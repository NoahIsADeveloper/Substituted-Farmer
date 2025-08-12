--!strict
--!optimize 2

local AST = require("./Utils/AST")
local Values = require("./Utils/Runtime")

local Evaluation = {}

function Evaluation:Evaluate(ast: AST.Statement): (Values.Value)
	return nil :: any
end

return Evaluation