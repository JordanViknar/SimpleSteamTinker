--!strict
local Application = {}

local process = require("@lune/process")
local fs = require("@lune/fs")

local metadata = require("./Metadata")
local Filesystem = require("./Utilities").Filesystem
local Logging = require("./Utilities").Logging
local Steam = require("./Steam")

function Application.start()
	-- Startup time
	local totalStartupTimeVar = os.clock()

	--[[ 
		Chapter 0 : Preparing the environment
		We need to create the config folder if it doesn't exist.
	]]
	
	-- Prepare folders if necessary
	for _, folder in ipairs({metadata.folders.config, metadata.folders.gamesConfig, metadata.folders.cache}) do
		Filesystem.createOrUseDirectory(folder)
	end

	-- Development version detection
	if metadata.version:find("dev") then
		Logging.write("warning", "DEVELOPMENT VERSION")
		-- Put the arguments inside the cache folder for testing purposes
		fs.writeFile(metadata.folders.cache.."/arguments.txt", table.concat(process.args, "\n"))
	end

	--[[
		Chapter 1 : Game management
		What's the Steam config ? Is this being started through Steam or alone ? What to do ?!
	]]
	local steamConfig = Steam.Configuration.getSteamConfiguration()
	Logging.write("speed", totalStartupTimeVar)
end

return Application
