-- Internal Modules
local toolObject = require("modules.objects.toolObject")

local name = "gamemoderun"
local type = "executable"
local usage = function(command)
	return "gamemoderun "..command
end

return toolObject:new(name, type, usage)
