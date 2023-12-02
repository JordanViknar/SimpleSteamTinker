-- Startup time
local totalStartupTimeVar = os.clock()

-- Internal Modules
local logSystem = require("modules.general.logSystem")
local fsUtils = require("modules.general.fsUtils")
local systemUtils = require("modules.general.systemUtils")
local steamUtils = require("modules.steam.steamUtils")
local programMetadata = require("modules.extra.programMetadata")
local gameLauncher = require("modules.tools.gameLauncher")

if programMetadata.version:find("dev") then
	logSystem.log("warning", "DEVELOPMENT VERSION")
end

-- Garbage collection settings
collectgarbage("incremental")

--[[ 
	Chapter 0 : Preparing the environment
	We need to create the config folder if it doesn't exist.
]]
-- Create the config folder if it doesn't exist
fsUtils.createOrUseDirectory(programMetadata.folders.config)
-- And the games folder inside of it
fsUtils.createOrUseDirectory(programMetadata.folders.gamesConfig)

-- Create the cache folder if it doesn't exist
fsUtils.createOrUseDirectory(programMetadata.folders.cache)

-- Put the arguments inside the cache folder for testing purposes
local cacheFile = io.open(programMetadata.folders.cache.."/lastArguments.txt", "w")
if not cacheFile then
	logSystem.log("error", "Unable to open cache file.")
else
	cacheFile:write(table.concat(arg, "\n"))
	cacheFile:close()
end

--[[
	Chapter 1 : Game management
	What's the Steam config ? Is this being started through Steam or alone ? What to do ?!
]]

-- We retrieve games registered in Steam.
local steamGames = require("modules.steam.steamConfigProvider")
collectgarbage("collect")

-- We check if we're starting a Steam game or not through the arguments.
local gameStartStatus = steamUtils.isSteamArgs(arg)

if gameStartStatus == "steamGame" then
	local game = steamGames[arg[3]:gsub("AppId=", "")]

	-- We notify the user that SimpleSteamTinker is running.
	logSystem.log("info", "Starting "..game.name.."...")
	systemUtils.sendNotification(programMetadata.name.." is starting...", "Detected "..game.name, "normal", true)

	-- For every argument that is a path, we put \ next to the spaces
	for i, v in ipairs(arg) do
		if fsUtils.exists(v) then
			arg[i] = v:gsub(" ", "\\ ")
		end
	end

	-- We prepare the command
	local command = table.concat(arg, " ")

	logSystem.log("info", "Applying settings for "..game.name.."...")
	command = gameLauncher.prepareGameLaunch(game, command)

	if os.execute(command) then
		os.exit(0)
	else
		systemUtils.sendNotification(programMetadata.name.." crashed !", "Something bad happened while running "..game.name..".", "critical", true)
		os.exit(1)
	end
elseif gameStartStatus == "SteamTinkerLaunch" or (arg[3] and steamGames[arg[3]:gsub("AppId=", "")].status == "SteamTinkerLaunch") then
	-- We notify the user that SteamTinkerLaunch is running.
	logSystem.log("error", "Can't use "..programMetadata.name.." ! SteamTinkerLaunch detected.")
	systemUtils.sendNotification("Can't use "..programMetadata.name.." !", "SteamTinkerLaunch detected.", "critical", true)

	-- For every argument that is a path, we put \ next to the spaces
	for i, v in ipairs(arg) do
		if fsUtils.exists(v) then
			arg[i] = v:gsub(" ", "\\ ")
		end
	end

	-- We prepare the command
	local command = table.concat(arg, " ")

	os.execute(command)
	os.exit(0)
end
logSystem.log("info", "No game to be launched detected. Launching interface...")



--[[
	Chapter 2 : The main window
	No games started. Time to cook some Libadwaita goodness then.
]]

-- External Modules
local lgi = require("lgi")
local Adw = lgi.Adw

-- Application
local app = Adw.Application({ 
	application_id = programMetadata.developer.."."..programMetadata.name,
})

-- Sort Steam games alphabetically
local newSteamGamesTable = {}
for _, v in pairs(steamGames) do
	table.insert(newSteamGamesTable, v)
end
table.sort(newSteamGamesTable, function(a, b) return a.name < b.name end)
steamGames = newSteamGamesTable
newSteamGamesTable = nil

-- Time to start the application
local timeStart = os.clock()
function app:on_startup()
	require("modules.ui.mainWindow")(app, steamGames)
end

function app:on_activate()
	logSystem.log("speed", timeStart)
	logSystem.log("info", "Startup time : "..os.clock()-totalStartupTimeVar.." seconds.")
	self.active_window:present()
end

return app:run(arg)
