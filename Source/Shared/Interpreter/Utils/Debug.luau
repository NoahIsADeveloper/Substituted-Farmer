local AST = require("./AST")

local Module = {}

function Module:Error(node: AST.Statement, errorMessage: string)
	local message = `{errorMessage}\nBetween ({node.range[1]}-{node.range[2]})`
	error(message)
end

return Module