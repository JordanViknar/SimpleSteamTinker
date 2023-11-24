-- External Modules
local lgi = require("lgi")
local GObject = lgi.GObject

-- Internal Modules
local systemUtils = require("modules.general.systemUtils")
local configManager = require("modules.config.configManager")

local lgiHelper = {}

--[[
	This function helps replacing signals on widgets.
	For example, if you want to replace the "on_clicked" signal of a button.
	
	It avoids bugs like opening a game's directory also opening the previous ones.
]]
local signalList = {}
function lgiHelper.replaceSignal(originalObject, signal, action)
	-- We create a table for the object if it doesn't exist.
	signalList[originalObject] = signalList[originalObject] or {}

	-- If the object already has an event connected to the same signal, we disconnect it.
	if signalList[originalObject][signal] then GObject.signal_handler_disconnect(originalObject, signalList[originalObject][signal]) end

	-- We connect the new signal.
	signalList[originalObject][signal] = originalObject[signal]:connect(action)
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
-- Workaround for :get_active() being buggy-ish.
local function wait(seconds)
	local start = os.time()
	repeat until os.time() > start + seconds
end

function lgiHelper.connectUtilityToButton(id, button, utility, property, setting)
	if systemUtils.isInstalled(utility) then
		button:set_sensitive(true)
		button:set_active(property)
		lgiHelper.replaceSignal(button, "on_activated", function()
			wait(0.1)
			configManager.modifyGameConfig(id, setting, not button:get_active())
		end)
	else
		button:set_sensitive(false)
		button:set_active(false)
		button.has_tooltip = true
		button.tooltip_text = "Utility '"..utility.."' is not installed on your system."
	end
end

return lgiHelper
