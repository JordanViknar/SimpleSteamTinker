-- External Modules
local lgi = require("lgi")
local GObject = lgi.GObject

-- Internal Modules
local systemUtils = require("modules.general.systemUtils")
local configManager = require("modules.config.configManager")

local lgiHelper = {}

--[[
	Name : function lgiHelper.replaceSignal(object, signal, action)
	Description : This function helps replacing signals on widgets.
	For example, if you want to replace the "on_clicked" signal of a button.
	
	It avoids bugs like opening a game's directory also opening the previous ones.
	Arg 1 : The object to modify.
	Arg 2 : The signal to replace.
	Arg 3 : The function to run (when clicking for example).
]]
local signalList = {}
function lgiHelper.replaceSignal(object, signal, action)
	lgiHelper.removeSignal(object, signal)

	if signalList[object] == nil then signalList[object] = {} end
	signalList[object][signal] = object[signal]:connect(action)
end

--[[
	Name : function lgiHelper.removeSignal(object, signal)
	Description : Simply deactivate the function of a button.
	Arg 1 : The object to modify.
	Arg 2 : The signal to remove.
]]
function lgiHelper.removeSignal(object, signal)
	-- We create a table for the object if it doesn't exist.
	if signalList[object] == nil then signalList[object] = {} end
	-- If the object already has an event connected to the same signal, we disconnect it.
	if signalList[object][signal] then
		GObject.signal_handler_disconnect(object, signalList[object][signal])
		signalList[object][signal] = nil
	end
end

--[[
	Name : function lgiHelper.connectUtilityToButton(id, button, utility, property, setting)
	Description : Connects a utility to a button.
	Arg 1 : string id : The game's ID.
	Arg 2 : The button to connect.
	Arg 3 : string utility : The utility's name.
	Arg 4 : string property : The property to connect.
	Arg 5 : string setting : The setting to modify.
]]
function lgiHelper.connectUtilityToButton(id, button, utility, property, setting)
	local signal = "on_state_set"
	lgiHelper.removeSignal(button, signal)

	-- If utility begins with /, then it's a file path.
	local isPresent = systemUtils.isInstalled(utility)

	if isPresent then
		button:set_sensitive(true)
		button:set_active(property)

		if signalList[button] == nil then signalList[button] = {} end
		signalList[button][signal] = button[signal]:connect(function()
			configManager.modifyGameConfig(id, setting, button:get_active())
		end)
	else
		button:set_sensitive(false)
		button:set_active(false)
		button.has_tooltip = true
		button.tooltip_text = "'"..utility.."' is not present on your system."
	end
end

return lgiHelper
