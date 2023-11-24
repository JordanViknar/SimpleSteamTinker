-- Internal Modules
local logSystem = require("modules.general.logSystem")
local systemUtils = require("modules.general.systemUtils")
local configManager = require("modules.config.configManager")

local gameLauncher = {}

function gameLauncher.prepareGameLaunch(game, command)
	-- First we retrive the configuration
	local gameConfig
	local status, result = pcall(function(value)
		gameConfig = configManager.getGameConfig(value)
	end, game.id)

	if not status then
		logSystem.log("error", "Couldn't retrieve configuration for "..game.name..". Error : "..result)
		systemUtils.sendNotification("Couldn't retrieve configuration for "..game.name.." !", result, "critical", true)
		return command
	end

	-- MangoHud
	if gameConfig.utilities.mangohud.enabled and systemUtils.isInstalled("mangohud") then
		command = "mangohud "..command
	end

	-- GameMode
	if gameConfig.utilities.gamemode.enabled and systemUtils.isInstalled("gamemoderun") then
		command = "gamemoderun "..command
	end

	return command
end

return gameLauncher
