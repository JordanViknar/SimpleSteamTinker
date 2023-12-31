-- Internal Modules
local logSystem = require("modules.general.logSystem")
local systemUtils = require("modules.general.systemUtils")
local configManager = require("modules.config.configManager")
local programMetadata = require("modules.extra.programMetadata")

local gameLauncher = {}

function gameLauncher.prepareGameLaunch(game, command)
	-- First we retrive the configuration
	local gameConfig
	local status, result = pcall(function(value)
		gameConfig = configManager.getGameConfig(value)
	end, game.id)

	if not status then
		logSystem.log("error", "Couldn't retrieve configuration for "..game.name..". Error : "..result)
		systemUtils.sendNotification("Couldn't retrieve configuration for "..game.name.." !", result, "error")
		return command
	end

	-- We get the list of utilities
	local utilities = require("modules.utilitiesList")(gameConfig)

	-- Environment variables : Part 1
	local environmentVars = {}

	-- We iterate through the utilities and enable them if they are installed
	for _, utility in pairs(utilities) do
		if utility[2] --[[= Utility is enabled]] and utility[1].isInstalled then
			if utility[1].toolType == "executable" then
				command = utility[1].usage(command, gameConfig)
			elseif utility[1].toolType == "environmentVariable" then
				table.insert(environmentVars, utility[1].usage(command, gameConfig))
			end
		end
	end

	-- Special case for switcherooctl, some Steam launch desktop files force the dGPU on games even when disabled.
	if gameConfig.dgpu.enabled == false and utilities[2][1].isInstalled then
		-- We add the environment variables to forcefully disable the dGPU
		table.insert(environmentVars, "DRI_PRIME=0 __NV_PRIME_RENDER_OFFLOAD=0 __VK_LAYER_NV_optimus=none __GLX_VENDOR_LIBRARY_NAME=none")
	end

	-- Environment variables not linked to a particular utility
	if game.os_platform == "Linux" then
		if gameConfig.misc.sdl_wayland == true then
			table.insert(environmentVars, "SDL_VIDEODRIVER=\"wayland,x11\"")
		else -- We force X11 to be used, just in case.
			table.insert(environmentVars, "SDL_VIDEODRIVER=\"x11\"")
		end
	end

	-- We convert the environment variables table to a string
	if environmentVars ~= {} then
		local envVarString = table.concat(environmentVars, " ")
		command = "env "..envVarString.." "..command
	end

	-- Print the final command in cache for debugging purposes
	local cacheFile = io.open(programMetadata.folders.cache.."/lastCommand.txt", "w")
	if not cacheFile then
		logSystem.log("error", "Unable to open cache file.")
	else
		cacheFile:write(command)
		cacheFile:close()
	end

	return command
end

return gameLauncher
