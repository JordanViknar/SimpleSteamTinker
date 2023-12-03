-- Internal Modules
local toolObject = require("modules.objects.toolObject")

local name = "mangohud"
local type = "executable"
local usage = function(command)
	return "mangohud "..command
end

return toolObject:new(name, type, usage)
