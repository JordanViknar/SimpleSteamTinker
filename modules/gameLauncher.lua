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
	if gameConfig.dgpu.enabled == false and utilities[3][1].isInstalled then -- Should use names instead of indexes later
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
	elseif game.os_platform == "Windows" then
		-- Direct3D
		if gameConfig.proton.direct3d.enable_direct3d9 == false then table.insert(environmentVars, "PROTON_NO_D3D9=1") end
		if gameConfig.proton.direct3d.enable_direct3d10 == false then table.insert(environmentVars, "PROTON_NO_D3D10=1") end
		if gameConfig.proton.direct3d.enable_direct3d11 == false then table.insert(environmentVars, "PROTON_NO_D3D11=1") end
		if gameConfig.proton.direct3d.enable_direct3d12 == false then table.insert(environmentVars, "PROTON_NO_D3D12=1") end
		if gameConfig.proton.direct3d.use_wined3d == true then table.insert(environmentVars, "PROTON_USE_WINED3D=1") end
		-- Sync
		if gameConfig.proton.sync.enable_esync == false then table.insert(environmentVars, "PROTON_NO_ESYNC=1") end
		if gameConfig.proton.sync.enable_fsync == false then table.insert(environmentVars, "PROTON_NO_FSYNC=1") end
		-- NVIDIA
		if gameConfig.proton.nvidia.enable_nvapi == true then table.insert(environmentVars, "PROTON_ENABLE_NVAPI=1") end
		if gameConfig.proton.nvidia.hide_nvidia_gpu == true then table.insert(environmentVars, "PROTON_HIDE_NVIDIA_GPU=1") end
		-- FSR
		if gameConfig.proton.fsr.enabled == true then
			table.insert(environmentVars, string.format(
				"WINE_FULLSCREEN_FSR=1 WINE_FULLSCREEN_FSR_STRENGTH=%s WINE_FULLSCREEN_FSR_MODE=%s",
				gameConfig.proton.fsr.sharpness,
				gameConfig.proton.fsr.upscaling_mode
			))
			if gameConfig.proton.fsr.resolution.enabled == true then
				table.insert(environmentVars, string.format(
					"WINE_FULLSCREEN_FSR_CUSTOM_MODE=%sx%s",
					gameConfig.proton.fsr.resolution.width,
					gameConfig.proton.fsr.resolution.height
				))
			end
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
