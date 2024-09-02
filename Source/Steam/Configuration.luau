local process = require("@lune/process")

local Logging = require("../Utilities").Logging
local SteamUtilities = require("./Utilities")
local VDFParser = require("./VDFParser")

type loginusers_vdf = {
	users : {
		[number] : {
			AccountName : string,
			MostRecent : number,
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
							-- Note : More options are available, but unused by STweaker
							LaunchOptions : string?
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

	local activeUserID = Configuration.Private.getMostRecentUserID(userConfiguration)
	local userParameters = userConfiguration.users[activeUserID]

	--[[
		Chapter 2 : We recover the user config to get which games have the tool enabled.
	]]
	local localconfig_vdf = Configuration.Private.getLocalConfigVDF(userParameters.SteamID3)

	local userGameConfigurations = localconfig_vdf.UserLocalConfigStore.Software.Valve.Steam.apps

	--[[
		Chapter 3 : We recover the Steam library config to get the list of games.
		We can't use just libraryfolders.vdf to get the game IDs, as Steam seems to not always update it immediately.
	]]
	local libraries = Configuration.Private.getLibraries()

	print(userParameters, userGameConfigurations, libraries)

	return
end

-- Private

function Configuration.Private.VDFHandler(filePath: string, errorMessage: string): any
	Logging.write("data", "Parsing VDF file : " .. filePath)
	local timeStart = os.clock()

	local result, parsedData = pcall(VDFParser.parseFile, filePath)
	if not result then
		error(errorMessage)
	else
		Logging.write("speed", timeStart)
		return parsedData
	end
end


-- loginuser.vdf

function Configuration.Private.getUsersConfiguration() : loginusers_vdf
	local usersData: loginusers_vdf = Configuration.Private.VDFHandler (
		process.env.HOME.."/.local/share/Steam/config/loginusers.vdf", 
		"Failed to parse loginusers.vdf file."
	)

	for userID, userParameters in pairs(usersData.users) do
		userParameters.SteamID3 = SteamUtilities.convertToSteamID3(userID)
	end

	return usersData
end

function Configuration.Private.getMostRecentUserID(userData : loginusers_vdf) : number
	local activeUserID
	for id,data in pairs(userData.users) do
		if data.MostRecent == 1 then
			activeUserID = id
		end
	end
	return activeUserID
end

-- localconfig.vdf

function Configuration.Private.getLocalConfigVDF(SteamID3: number): localconfig_vdf
	return Configuration.Private.VDFHandler (
		process.env.HOME.."/.local/share/Steam/userdata/"..SteamID3.."/config/localconfig.vdf", 
		"Failed to parse active user localconfig.vdf file with SteamID3: " .. SteamID3
	)
end

-- libraryfolders.vdf

function Configuration.Private.getLibraries(): libraryfolders_vdf
	return Configuration.Private.VDFHandler (
		process.env.HOME.."/.local/share/Steam/config/libraryfolders.vdf", 
		"Failed to parse libraryfolders.vdf file."
	)
end

return Configuration.Public
