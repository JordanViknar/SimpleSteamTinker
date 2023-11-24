-- Internal Modules
local lgiHelper = require("modules.ui.lgiHelper")

return function(application, interface, steamGameData, gameSettings)
	local protonPage = interface:get_object("protonPage")
	if steamGameData.os_platform == "Windows" then
		protonPage.visible = true
	else
		protonPage.visible = false
	end
end
