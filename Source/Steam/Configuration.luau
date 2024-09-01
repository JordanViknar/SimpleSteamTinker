local process = require("@lune/process")

local Logging = require("../Utilities").Logging
local SteamUtilities = require("Utilities")
local VDFParser = require("VDFParser")

type loginusers_vdf = {
	users : {
		[number] : {
			AccountName : string,
			--PersonaName : string,
			--RememberPassword : boolean,
			--WantsOfflineMode : boolean,
			--SkipOfflineModeWarning : boolean,
			--AllowAutoLogin : boolean,
			MostRecent : boolean,
			--TimeStamp : number,
			SteamID3 : number -- Added manually later on
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

local Configuration = {}

Configuration.Private = {}
Configuration.Public = {}

-- Public

function Configuration.Public.getSteamConfiguration() : string?
	--[[
		Chapter 1 : We recover the Steam user config so we can get the last active user.
		And also the SteamID3 to access their settings folder.
	]]
	local userConfiguration = Configuration.Private.getUsersConfiguration()
	if typeof(userConfiguration) == "string" then
		return userConfiguration -- Error
	end

	local activeUserID = Configuration.Private.getMostRecentUserID(userConfiguration)
	local userParameters = userConfiguration.users[activeUserID]

	--[[
		Chapter 2 : We recover the user config to get which games have the tool enabled.
		This section would normally have quite an impact on performance.
		Thanks to some optimizations, however, the time is cut from 0.5 seconds to 0.04 seconds on my computer.
	]]
	local localconfig_vdf = Configuration.Private.getLocalConfigVDF(userParameters.SteamID3)
	if typeof(localconfig_vdf) == "string" then
		return localconfig_vdf -- Error
	end
	local userGameConfigurations = localconfig_vdf.UserLocalConfigStore.Software.Valve.Steam.apps

	--[[
		Chapter 3 : We recover the Steam library config to get the list of games.
		We can't use just libraryfolders.vdf to get the game IDs, as Steam seems to not always update it immediately.
	]]
	local libraries = Configuration.Private.getLibraries()
	if typeof(libraries) == "string" then
		return libraries -- Error
	end

	return
end

-- Private

-- loginuser.vdf

function Configuration.Private.getUsersConfiguration() : loginusers_vdf | string
	Logging.write("data", "Detecting user config...")
	local timeStart = os.clock()

	local result, usersData: loginusers_vdf = pcall(VDFParser.parseFile, (process.env.HOME.."/.local/share/Steam/config/loginusers.vdf"))
	if not result then
		return "Failed to parse loginusers.vdf."
	else
		Logging.write("speed", timeStart)

		for userID,userParameters in pairs(usersData.users) do
			userParameters.SteamID3 = SteamUtilities.convertToSteamID3(userID)
		end

		return usersData
	end
end

function Configuration.Private.getMostRecentUserID(userData : loginusers_vdf) : number
	local activeUserID
	for id,data in pairs(userData.users) do
		if data.MostRecent == true then
			activeUserID = id
		end
	end
	return activeUserID
end

-- localconfig.vdf

function Configuration.Private.getLocalConfigVDF(SteamID3 : number) : localconfig_vdf | string
	Logging.write("data", "Detecting active user game configs...")
	local timeStart = os.clock()

	local appParseSettings = {
		file = process.env.HOME.."/.local/share/Steam/userdata/"..SteamID3.."/config/localconfig.vdf",
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

	local result, localconfig_vdf: localconfig_vdf = pcall(VDFParser.parseFile, appParseSettings.file, appParseSettings.stopKeyList, appParseSettings.wordsFromLinesToRemove)
	if not result then
		return "Failed to parse active user localconfig.vdf with SteamID3 : "..SteamID3
	else
		Logging.write("speed", timeStart)
		return localconfig_vdf
	end
end

-- libraryfolders.vdf

function Configuration.Private.getLibraries() : libraryfolders_vdf | string
	Logging.write("data", "Detecting games...")
	local timeStart = os.clock()

	local result, libraryFolders: libraryfolders_vdf = pcall(VDFParser.parseFile, process.env.HOME.."/.local/share/Steam/config/libraryfolders.vdf")
	if not result then
		return "Failed to parse libraryfolders.vdf."
	else
		Logging.write("speed", timeStart)
		return libraryFolders
	end
end

return Configuration.Public
