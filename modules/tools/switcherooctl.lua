-- Internal Modules
local toolObject = require("modules.objects.toolObject")

local name = "switcherooctl"
local type = "executable"
local usage = function(command, config)
	if config.utilities.zink.enabled == true then
		-- We let Zink handle the dGPU
		return command
	else
		return "switcherooctl launch "..command
	end
end

return toolObject:new(name, type, usage)
