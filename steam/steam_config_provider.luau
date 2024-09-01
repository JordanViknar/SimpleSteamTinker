--!strict

-- Modules
local process = require("@lune/process")

local logSystem = require("../general").logSystem
-- local fsUtils = require("../general").fsUtils
local steamUtils = require("steam_utils")
local vdfParser = require("vdf_parser")

-- Definitions
type SteamID64_Dec = number
type SteamID3 = number

type loginusers_vdf = {
	users : {
		[SteamID64_Dec] : {
			AccountName : string,
			--PersonaName : string,
			--RememberPassword : boolean,
			--WantsOfflineMode : boolean,
			--SkipOfflineModeWarning : boolean,
			--AllowAutoLogin : boolean,
			MostRecent : boolean,
			--TimeStamp : number,
			SteamID3 : SteamID3 -- Added manually later on
		}
	}
}
type localconfig_vdf = {
	UserLocalConfigStore : {
		Software : {
			Valve : {
				Steam : {
					apps : {
						[number] : {
							--[[cloud : {
								last_sync_state : string?,
								quota_bytes : number?,
								quota_files : number?,
								used_bytes : number?,
								used_files : number?,
							}?,
							LastPlayed : number?,
							Playtime : (number | boolean)?,
							BadgeData : string?,]]--
							LaunchOptions : string?,
							--[[Playtime2wks : boolean?,
							autocloud : {
								lastexit : number,
								lastlaunch : number,
							}?]]
						}
					}
				}
			}
		}
	}
}
type libraryfolders_vdf = {
	libraryfolders : {
		[number] : {
			apps : {
				[number] : number
			},
			--contentid : number,
			--label : string,
			path : string,
			--time_last_update_corruption : number | boolean,
			--totalsize : boolean,
			--update_clean_bytes_tally : number | boolean
		}
	}
}

-- Timer
local timeStart: number

--[[
	Chapter 1 : We recover the Steam user config so we can get the last active user.
	And also the SteamID3 to access their settings folder.
]]
logSystem.log("data", "Detecting user config...")
timeStart = os.clock()

local result, userData: loginusers_vdf = pcall(vdfParser.parseFile, (process.env.HOME.."/.local/share/Steam/config/loginusers.vdf"))
if not result then
	logSystem.log("error", "Failed to parse loginusers.vdf.")
	return nil
end

-- We add the SteamID3 to the user data, and also grab the most recent user's ID while we're at it.
local activeUserID: SteamID64_Dec
for id,data in pairs(userData.users) do
	-- SteamID3
	data.SteamID3 = steamUtils.convertToSteamID3(id)

	-- Most recent
	if data.MostRecent == true then
		activeUserID = id
	end
end
logSystem.log("speed", timeStart)

print(userData)

logSystem.log("info", "Active user : "..userData.users[activeUserID].AccountName)

--[[
	Chapter 2 : We recover the user config to get which games have the tool enabled.
	This section would normally have quite an impact on performance.
	Thanks to some optimizations, however, the time is cut from 0.5 seconds to 0.04 seconds on my computer.
]]
logSystem.log("data", "Detecting active user game configs...")
timeStart = os.clock()

local appParseSettings = {
	file = process.env.HOME.."/.local/share/Steam/userdata/"..userData.users[activeUserID].SteamID3.."/config/localconfig.vdf",
	stopKeyList = {
		"UserLocalConfigStore",
		"Software",
		"Valve",
		"Steam",
		"apps"
	},
	wordsFromLinesToRemove = {
		"CachedCommunityPreferences",
		"UIStoreLocalState",
		"CachedStorePreferences",
		"CachedNotificationPreferences",
		"SteamVoiceSettings_",
		"UIStoreLocalSteamUIState",
		"UIStoreLocalGamepadState",
		"GetEquippedProfileItemsForUser",
		"CTextFilterStore_strBannedPattern",
		"CTextFilterStore_strCleanPattern",
		"trendingstore_storage",
		"playnextstore_storage",
		"GetEquippedProfileItemsForUser"
	}
}

local result, localconfig_vdf: localconfig_vdf = pcall(vdfParser.parseFile, appParseSettings.file, appParseSettings.stopKeyList, appParseSettings.wordsFromLinesToRemove)
if not result then
	logSystem.log("error", "Failed to parse active user localconfig.vdf with SteamID3 : "..userData.users[activeUserID].SteamID3)
	return nil
end
logSystem.log("speed", timeStart)

local userAppSettings = localconfig_vdf.UserLocalConfigStore.Software.Valve.Steam.apps
print(userAppSettings)

--[[
	Chapter 3 : We recover the Steam library config to get the list of games.
	We can't use just libraryfolders.vdf to get the game IDs, as Steam seems to not always update it immediately.
]]
logSystem.log("data", "Detecting games...")
timeStart = os.clock()

local result, libraryFolders: libraryfolders_vdf = pcall(vdfParser.parseFile, process.env.HOME.."/.local/share/Steam/config/libraryfolders.vdf")
if not result then
	logSystem.log("error", "Failed to parse libraryfolders.vdf.")
	return nil
end
logSystem.log("speed", timeStart)

print(libraryFolders)
