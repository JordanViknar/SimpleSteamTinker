-- Internal Modules
local toolObject = require("modules.objects.toolObject")

--[[
	I was tempted to separate this tool in 2 options : one for the utility (supports Vulkan & OpenGL),
	and another for the environment variable which can be used with Vulkan games.
	However, I chose to stay simple and use what works for all : the utility.
	This is seemingly also the approach SteamTinkerLaunch goes with, judging from its wiki.
]]

local name = "obs-gamecapture"
local type = "executable"
local usage = function(command)
	return "obs-gamecapture "..command
end

return toolObject:new(name, type, usage)
