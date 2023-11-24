-- Internal Modules
local logSystem = require("general_modules.logSystem")
local vdfParser = require("steam_modules.vdfParser")
local steamUtils = require("steam_modules.steamUtils")
local programMetadata = require("extra_modules.programMetadata")
local fsUtils = require("general_modules.fsUtils")

-- Timer
local timeStart

--[[
	Chapter 1 : We recover the Steam user config so we can get the last active user.
	And also the SteamID3 to access their settings folder.
]]
logSystem.log("fileRead", "Detecting user config...")
timeStart = os.clock()
local userData = vdfParser.parseFile(os.getenv("HOME").."/.local/share/Steam/config/loginusers.vdf")

-- We add the SteamID3 to the user datas, and also grab the most recent user's ID while we're at it.
local activeUserID
for id,data in pairs(userData["users"]) do
	-- SteamID3
	local converted = steamUtils.convertToSteamID3(id)
	data["steamID3"] = {
		pure = converted,
		onlyId = converted:gsub("%[U:1:", ""):gsub("%]", "")
	}

	-- Most recent
	if data["MostRecent"] == "1" then
		activeUserID = id
	end
end
logSystem.log("speed", timeStart)
logSystem.log("info", "Active user : "..userData["users"][activeUserID]["AccountName"])

--[[
	Chapter 2 : We recover the user config to get which games have the tool enabled.
	This section would normally have quite an impact on performance.
	Thanks to some optimizations, however, the time is cut from 0.5 seconds to 0.04 seconds on my computer.
]]
logSystem.log("fileRead", "Detecting active user game configs...")
timeStart = os.clock()

local userAppSettings = vdfParser.parseFile(
	os.getenv("HOME").."/.local/share/Steam/userdata/"..userData["users"][activeUserID]["steamID3"]["onlyId"].."/config/localconfig.vdf",
	{"UserLocalConfigStore","Software","Valve","Steam","apps"},
	{"CachedCommunityPreferences", "CachedStorePreferences", "CachedNotificationPreferences", "SteamVoiceSettings_", "UIStoreLocalSteamUIState", "CTextFilterStore_strBannedPattern", "trendingstore_storage", "GetEquippedProfileItemsForUser"} -- Optimization : we remove big lines that we don't need.
)["UserLocalConfigStore"]["Software"]["Valve"]["Steam"]["apps"]
logSystem.log("speed", timeStart)

--[[
	Chapter 3 : We recover the Steam library config to get the list of games.
	We can't use just libraryfolders.vdf to get the game IDs, as Steam seems to not always update it immediately.
]]
logSystem.log("fileRead", "Detecting games...")
timeStart = os.clock()

local libraryFolders = vdfParser.parseFile(os.getenv("HOME").."/.local/share/Steam/config/libraryfolders.vdf")

-- Steam Game Object
local SteamGame = require("objects_modules.steamGameObject")
-- And list
local steamGames = {}

-- For each library
for _,folderData in pairs(libraryFolders["libraryfolders"]) do
	-- We get the list of every appmanifest_*.acf file in the folder
	local appManifestsFileNames = fsUtils.getFilenamePatternInDirectory(folderData["path"].."/steamapps", "appmanifest_")
	for _,appId in pairs(appManifestsFileNames) do
		-- We convert the filename to the app ID
		appId = appId:gsub("appmanifest_", ""):gsub(".acf", "")

		local appManifest = vdfParser.parseFile(folderData.path.."/steamapps/appmanifest_"..appId..".acf")
		-- We create a SteamGame object
		local steamGame = SteamGame:new(
			appId,
			appManifest["AppState"]["name"],
			folderData["path"],
			folderData.path.."/steamapps/common/"..appManifest["AppState"]["installdir"]
		)
		-- We add it to the list
		steamGames[appId] = steamGame
	end
end

-- And now we merge user game data and game data
for gameID, data in pairs(userAppSettings) do
	-- We check if the game is actually installed before attempting a merge.
	if steamGames[gameID] ~= nil then
		-- Tool status
		if data["LaunchOptions"] and string.find(data["LaunchOptions"],programMetadata.executable) then
			steamGames[gameID].status = true
		end
		if data["LaunchOptions"] and string.find(data["LaunchOptions"],"steamtinkerlaunch") then
			steamGames[gameID].status = "SteamTinkerLaunch"
		end
	end
end
logSystem.log("speed", timeStart)

--[[
	Chapter 4 : We check if the game is in the compat list
]]
logSystem.log("fileRead","Detecting games' platforms...")
timeStart = os.clock()

local compatList = vdfParser.parseFile(
	os.getenv("HOME").."/.local/share/Steam/userdata/"..userData["users"][activeUserID]["steamID3"]["onlyId"].."/config/compat.vdf"
)["platform_overrides"]

for gameID,_ in pairs(compatList) do
	-- Proton Status
	--[[
		WARNING : METHOD WRONGLY SETS WINDOWS STATUS FOR LINUX GAMES THAT WERE PREVIOUSLY USING PROTON
		Workaround : Check if Windows version contains Linux executable or shell script.
	]]
	if steamGames[gameID] and steamGames.type ~= "proton" then
		if not fsUtils.directoryContainsLinuxData(steamGames[gameID].location) then
			steamGames[gameID].os_platform = "Windows"
		else
			logSystem.log("warning", "Game "..steamGames[gameID].name.." was listed as Windows game, but contains Linux data. Assuming it runs with Linux...")
		end
	end
end
logSystem.log("speed", timeStart)

return steamGames
