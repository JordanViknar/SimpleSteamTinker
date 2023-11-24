-- Internal Modules
local lgiHelper = require("ui_modules.lgiHelper")
local systemUtils = require("general_modules.systemUtils")
local configManager = require("config_modules.configManager")

return function(application, interface, steamGameData, gameSettings)
	-- GameMode
	lgiHelper.connectUtilityToButton(steamGameData.id, interface:get_object("gamemode_switch"), "gamemoderun", gameSettings.utilities.gamemode.enabled, "utilities.gamemode.enabled")
end
