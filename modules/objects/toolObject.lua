-- Internal Modules
local systemUtils = require("modules.general.systemUtils")
local logSystem = require("modules.general.logSystem")

Tool = {
	metatable = {
		__index = Tool
	}
}

function Tool:new (toolName, toolType, modification)
	assert(toolName)
	assert(toolType == "executable" or toolType == "environmentVariable", "Invalid tool type for tool "..toolName..".")
	assert(type(modification) == "function", "Invalid modification for tool "..toolName..".")

	return setmetatable({
		toolName = toolName,
		toolType = toolType, -- "executable" or "environmentVariable"
		isInstalled = systemUtils.isInstalled(toolName),
		usage = modification
	}, Tool.metatable)
end

return Tool
