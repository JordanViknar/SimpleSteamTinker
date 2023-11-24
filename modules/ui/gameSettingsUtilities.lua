-- Internal Modules
local lgiHelper = require("modules.ui.lgiHelper")
local systemUtils = require("modules.general.systemUtils")
local configManager = require("modules.config.configManager")

return function(application, interface, steamGameData, gameSettings)
	-- GameMode
	lgiHelper.connectUtilityToButton(steamGameData.id, interface:get_object("gamemode_switch"), "gamemoderun", gameSettings.utilities.gamemode.enabled, "utilities.gamemode.enabled")
end
