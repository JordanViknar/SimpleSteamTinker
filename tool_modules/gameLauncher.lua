-- Internal Modules
local logSystem = require("general_modules.logSystem")
local systemUtils = require("general_modules.systemUtils")
local configManager = require("config_modules.configManager")

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

	-- GameMode
	if gameConfig.utilities.gamemode.enabled and systemUtils.isInstalled("gamemoderun") then
		command = "gamemoderun "..command
	end

	return command
end

return gameLauncher
