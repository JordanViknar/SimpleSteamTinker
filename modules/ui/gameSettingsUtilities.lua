-- Internal Modules
local lgiHelper = require("modules.ui.lgiHelper")

return function(application, interface, steamGameData, gameSettings)
	-- GameMode
	lgiHelper.connectUtilityToButton(steamGameData.id, interface:get_object("gamemode_switch"), "gamemoderun", gameSettings.utilities.gamemode.enabled, "utilities.gamemode.enabled")

	-- MangoHud
	lgiHelper.connectUtilityToButton(steamGameData.id, interface:get_object("mangohud_switch"), "mangohud", gameSettings.utilities.mangohud.enabled, "utilities.mangohud.enabled")

	-- Zink
	lgiHelper.connectUtilityToButton(steamGameData.id, interface:get_object("zink_switch"), "/usr/lib/dri/zink_dri.so", gameSettings.utilities.zink.enabled, "utilities.zink.enabled")
end
