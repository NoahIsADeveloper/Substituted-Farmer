--!strict
--!optimize 2

local AST = require("./AST")

local Debug = {}

function Debug:Error(node: AST.Statement, errorMessage: string)
	local message = `{errorMessage}\nBetween ({node.range[1]}-{node.range[2]})`
	error(message)
end

return Debug