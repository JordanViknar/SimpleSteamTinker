local SteamApp = require("../Classes/SteamApp")

local GameConfiguration = require("@Configuration/").Games.Functions

local Launcher = {}

function Launcher.prepareLaunchCommand(appData: SteamApp.SteamApp): { string }
	-- First and foremost, we recover the configuration of the game.
	local ok, appConfig = pcall(GameConfiguration.getGameConfiguration, appData)
	if not ok then
		error("Failed to get game configuration for " .. appData.name .. " (" .. appData.appID .. ").")
	end

	error("Not implemented.")
end

return Launcher
