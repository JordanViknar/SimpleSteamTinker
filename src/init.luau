local fs = require("@lune/fs")
local process = require("@lune/process")

local Filesystem = require("@Utilities/Filesystem")
local Launcher = require("@Launcher/Functions")
local Logging = require("@Utilities/Logging")
local Metadata = require("./Metadata")
local Steam = {
	Configuration = require("@Steam/Configuration"),
	Utilities = require("@Steam/Utilities"),
}
local System = require("@Utilities/System")

local Application = {}

function Application.start()
	-- Prepare folders if necessary
	for _, folder in ipairs({
		Metadata.folders.config,
		Metadata.folders.gamesConfig,
		Metadata.folders.cache,
	}) do
		Filesystem.createOrUseDirectory(folder)
	end

	-- Development version detection
	if Metadata.version:find("dev") then
		Logging.write("warn", "This is a development version of " .. Metadata.name .. " !")
		-- Put the arguments inside the cache folder for testing purposes
		fs.writeFile(Metadata.folders.cache .. "/arguments.txt", table.concat(process.args, "\n"))
	end

	-- Check if we're launched through Steam, start the game with its settings if so
	local launchedAppID = Steam.Utilities.isSteamLaunch()
	if launchedAppID then
		Logging.write("info", "Launched through Steam (AppID " .. launchedAppID .. ").")
		Logging.separator()

		-- Load the Steam config
		local ok, steamConfig = pcall(Steam.Configuration.getSteamConfiguration)
		if not ok then
			Logging.write("error", "Failed to load Steam games.")
			System.sendNotification(Metadata.name, "Failed to load Steam games.", "critical", true)
			process.exit(1)
		end

		-- Load the game's data
		local gameData = steamConfig[launchedAppID]
		if not gameData then
			Logging.write("error", "No data found for game with AppID " .. launchedAppID .. ".")
			System.sendNotification(Metadata.name, "No data found for game with AppID " .. launchedAppID .. ".", "critical", true)
			process.exit(1)
		end

		-- Tell the user we found the game
		Logging.write("success", 'Detected "' .. gameData.name .. '" (' .. gameData.appID .. ") !")
		System.sendNotification(Metadata.name, "Detected " .. gameData.name .. ".", "normal", true)

		-- Go into the Game Launcher module.
		local command: { string } = Launcher.Functions.prepareLaunchCommand(gameData)
		print(command)
	else
		Logging.write("info", "Launched without Steam.")

		-- :( - Lune FFI is not implemented yet, so no interface.
		System.sendNotification(Metadata.name, "No graphical interface implemented yet.", "critical", true)
		error("No graphical interface implemented yet.")
	end
end

return Application
