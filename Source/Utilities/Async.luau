--!strict
local task = require("@lune/task")

local Async = {}

--[=[
	Executes a function asynchronously over all elements in a table.
	It's similar to Rust's rayon.

	@param tbl The table to iterate over.
	@param asyncFunc The asynchronous function to execute for each element.
]=]
function Async.asyncForEach(tbl: {any}, asyncFunc: (any, any) -> ())
	local total = 0
	local completed = 0
	
	for key, item in pairs(tbl) do
		total += 1
		task.spawn(function()
			asyncFunc(key, item)
			completed += 1
		end)
	end

	while completed < total do
		task.wait()
	end
end

return Async
