local Application = {}

local fs = require("@lune/fs")
local process = require("@lune/process")

local metadata = require("./Metadata")
local Filesystem = require("./Utilities").Filesystem
local Logging = require("./Utilities").Logging
local Steam = require("./Steam")

function Application.start()
	--[[
		Chapter 0 : Preparing the environment
		We need to create the config folder if it doesn't exist.
	]]
	-- Prepare folders if necessary
	for _, folder in ipairs({
		metadata.folders.config,
		metadata.folders.gamesConfig,
		metadata.folders.cache,
	}) do
		Filesystem.createOrUseDirectory(folder)
	end

	-- Development version detection
	if metadata.version:find("dev") then
		Logging.write("warn", "This is a development version of " .. metadata.name .. " !")
		-- Put the arguments inside the cache folder for testing purposes
		fs.writeFile(metadata.folders.cache .. "/arguments.txt", table.concat(process.args, "\n"))
	end

	--[[
		Chapter 1 : Game management
		Is this being started through Steam or alone ?
		What's the Steam config then ?
	]]
	local launchedAppID = Steam.Utilities.isSteamLaunch()
	if launchedAppID then
		Logging.write("info", "Launched through Steam (AppID " .. launchedAppID .. ").")
		Logging.separator()

		-- Load the Steam config
		local ok, steamConfig = pcall(Steam.Configuration.getSteamConfiguration)
		if not ok then
			Logging.write("error", "Failed to load Steam games.")
			process.exit(1)
		end

		-- Load the game's data
		local gameData = steamConfig[launchedAppID]
		if not gameData then
			Logging.write("error", "No data found for game with AppID " .. launchedAppID .. ".")
			process.exit(1)
		end

		Logging.write("success", 'Detected "' .. gameData.name .. '" (' .. gameData.appID .. ") !")
	else
		Logging.write("info", "Launched without Steam.")
		error("No graphical interface implemented yet.")
	end
end

return Application
