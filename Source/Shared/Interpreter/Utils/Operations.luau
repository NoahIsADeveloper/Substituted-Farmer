--!strict
--!optimize 2

return {
	["+"] = function(a: number, b: number)
		return a + b
	end,
	["-"] = function(a: number, b: number)
		return a - b
	end,
	["*"] = function(a: number, b: number)
		return a * b
	end,
	["/"] = function(a: number, b: number)
		return a / b
	end,
	["%"] = function(a: number, b: number)
		return a % b
	end,
	["^"] = function(a: number, b: number)
		return a ^ b
	end,
	[">"] = function(a: number, b: number)
		return a > b
	end,
	[">="] = function(a: number, b: number)
		return a >= b
	end,
	["<"] = function(a: number, b: number)
		return a < b
	end,
	["<="] = function(a: number, b: number)
		return a <= b
	end,
	["!="] = function(a: number, b: number)
		return a ~= b
	end,
	["=="] = function(a: number, b: number)
		return a == b
	end,
}