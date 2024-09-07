local task = require("@lune/task")

local Async = {}

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
