local fs = require("@lune/fs")
local serde = require("@lune/serde")

local SteamApp = require("../../Classes/SteamApp")
local Default = require("./Default")
local Metadata = require("../../Metadata")
local Logging = require("../../Utilities/Logging")

local function createGameConfiguration(appData : SteamApp.SteamApp) : Default.GameConfiguration
	local newConfig = Default.getDefaultGameConfiguration(appData)

	Logging.write("info", "Creating default configuration for game " .. appData.name .. " (" .. appData.appID .. ")...")
	local configString = serde.encode("toml", newConfig, true)
	fs.writeFile(string.format(
		"%s/%s.toml",
		Metadata.folders.gamesConfig,
		tostring(appData.appID)
	), configString)

	return newConfig
end

local GameConfigurations = {}

function GameConfigurations.getGameConfiguration(appData : SteamApp.SteamApp) : Default.GameConfiguration
	local configPath = string.format(
		"%s/%s.toml",
		Metadata.folders.gamesConfig,
		tostring(appData.appID)
	)

	if fs.metadata(configPath).exists then
		local configString = fs.readFile(configPath)
		return serde.decode("toml", configString)
	else
		return createGameConfiguration(appData)
	end
end

return GameConfigurations