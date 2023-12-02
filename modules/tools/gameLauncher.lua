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

	-- Environment variables : Part 1
	local environmentVars = {}

	-- DGPU
	if gameConfig.dgpu.enabled and systemUtils.isInstalled("switcherooctl") then
		command = "switcherooctl launch "..command
	end
	-- MangoHud
	if gameConfig.utilities.mangohud.enabled and systemUtils.isInstalled("mangohud") then
		command = "mangohud "..command
	end

	-- GameMode
	if gameConfig.utilities.gamemode.enabled and systemUtils.isInstalled("gamemoderun") then
		command = "gamemoderun "..command
	end

	-- Zink
	if gameConfig.utilities.zink.enabled then
		table.insert(environmentVars, "MESA_LOADER_DRIVER_OVERRIDE=zink")
	end

	-- Environment variables : Part 2
	if environmentVars ~= {} then
		local envVarString = table.concat(environmentVars, " ")
		command = "env "..envVarString.." "..command
	end

	return command
end

return gameLauncher
