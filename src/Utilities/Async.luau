local task = require("@lune/task")

--[=[
	@class Utilities.Async
]=]
local Async = {}

--[=[
	Executes a function in parallel over all elements in a table.
	It's similar to Rust's rayon.
	Pretty big upgrade compared to the previous implementation.

	@param tbl The table to iterate over.
	@param func The function to execute in parallel for each element.
]=]
function Async.asyncForEach(tbl: { any }, func: (any, any) -> ())
	local total = 0
	local completed = 0

	for key, item in pairs(tbl) do
		total += 1
		task.spawn(function()
			func(key, item)
			completed += 1
		end)
	end

	while completed < total do
		task.wait()
	end
end

return Async
