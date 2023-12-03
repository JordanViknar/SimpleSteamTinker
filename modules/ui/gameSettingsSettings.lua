-- Internal Modules
local lgiHelper = require("modules.ui.lgiHelper")

return function(application, interface, steamGameData, gameSettings)
	-- DGPU
	lgiHelper.connectUtilityToButton(steamGameData.id, interface:get_object("DGPU_Switch"), "switcherooctl", gameSettings.dgpu.enabled, "dgpu.enabled")
end
