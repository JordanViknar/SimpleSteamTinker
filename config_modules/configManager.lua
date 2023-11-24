-- Internal Modules
local gameConfigFolder = require("extra_modules.programMetadata").folders.gamesConfig
local fsUtils = require("general_modules.fsUtils")
local logSystem = require("general_modules.logSystem")

-- External Modules
local json = require("dkjson")

local configManager = {}

--[[
	Name : function configManager.createGameConfig(gameId)
	Description : Creates a config file for a game.
	Arg 1 : gameId (string) : The game's Steam ID.
	Return : The game's config.
]]
function configManager.createGameConfig(gameId)
	-- Grab the default template
	local gameConfig = require("config_modules.defaultConfigTemplate")
	gameConfig.steamGameId = gameId

	-- Write the new table to the file
	local path = string.format("%s/%s.json", gameConfigFolder, gameId)
	local file = assert(io.open(path, "w"), "Couldn't open " .. path .. " !")
	file:write(json.encode(gameConfig, { indent = false }))
	file:close()

	return gameConfig
end

--[[
	Name : configManager.getGameConfig(gameId)
	Description : Retrieves a game's config.
	Arg 1 : gameId (string) : The game's Steam ID.
]]
function configManager.getGameConfig(gameId)
	-- Check if the config exists
	local path = string.format("%s/%s.json", gameConfigFolder, gameId)
	if not fsUtils.exists(path) then
		local warningMsg = "Config for game " .. gameId .. " at " .. path .. " doesn't exist. Creating it..."
		logSystem.log("warning", warningMsg)
		return configManager.createGameConfig(gameId)
	end

	-- Read the file
	local file = assert(io.open(path, "r"), "Couldn't open " .. path .. " !")
	local fileContent = file:read("*a")
	file:close()

	return json.decode(fileContent)
end

--[[
	Name : function configManager.modifyGameConfig(gameId, dataToChange)
	Description : Modifies a game's config.
	Arg 1 : gameId (string) : The game's Steam ID.
	Arg 2 : dataToChange (string) : The data to change. Example : "steamGameId"
	Arg 3 : value (any) : The value to set.
	Return : The game's config.
]]
function configManager.modifyGameConfig(gameId, dataToChange, value)
	-- Grab the original config data
	local gameConfig = configManager.getGameConfig(gameId)

	-- Parse dataToChange
	local keys = {}
	for substring in dataToChange:gmatch("[^.]+") do
		keys[#keys + 1] = substring
	end

	-- Modify the table
	local pointer = gameConfig
	for i = 1, #keys - 1 do
		pointer = pointer[keys[i]] or {}
	end
	pointer[keys[#keys]] = value

	-- Write the new table
	local path = string.format("%s/%s.json", gameConfigFolder, gameId)
	local file = assert(io.open(path, "w"), "Couldn't open " .. path .. " !")

	file:write(json.encode(gameConfig))
	file:close()

	return gameConfig
end

return configManager
