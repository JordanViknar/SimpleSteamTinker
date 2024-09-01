--!strict
-- Startup time
local totalStartupTimeVar = os.clock()

-- Lune Modules
local process = require("@lune/process")
local fs = require("@lune/fs")

-- Internal Modules
local metadata = require("metadata")
local logSystem = require("general").logSystem
local fsUtils = require("general").fsUtils

--[[ 
	Chapter 0 : Preparing the environment
	We need to create the config folder if it doesn't exist.
]]
-- Create folders
fsUtils.createOrUseDirectory(metadata.folders.config)
fsUtils.createOrUseDirectory(metadata.folders.gamesConfig)
fsUtils.createOrUseDirectory(metadata.folders.cache)

-- Grab arguments
local arguments = process.args

-- Development version
if metadata.version:find("dev") then
	logSystem.log("warning", "DEVELOPMENT VERSION")
	-- Put the arguments inside the cache folder for testing purposes
	fs.writeFile(metadata.folders.cache.."/arguments.txt", table.concat(arguments, "\n"))
end

--[[
	Chapter 1 : Game management
	What's the Steam config ? Is this being started through Steam or alone ? What to do ?!
]]

local steamConfig = require("steam").steamConfig
