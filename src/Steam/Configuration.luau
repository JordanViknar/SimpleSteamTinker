local fs = require("@lune/fs")
local process = require("@lune/process")

local Utilities = require("../Utilities")
local Logging = Utilities.Logging
local Async = Utilities.Async
local Filesystem = Utilities.Filesystem
local SteamUtilities = require("./Utilities")
local VDFParser = require("./VDFParser")
local SteamApp = require("../Classes").SteamApp

-- --------------------------- Definitions -----------------------------

-- Steam files
-- Note : Most of the entries are unused and simply for informative purposes.

type loginusers_vdf = {
	users: {
		[number]: {
			AccountName: string,
			PersonaName: string,
			RememberPassword: number,
			WantsOfflineMode: number,
			SkipOfflineModeWarning: number,
			AllowAutoLogon: number,
			MostRecent: number,
			Timestamp: number,
		},
	},
}
type localconfig_vdf = {
	UserLocalConfigStore: {
		Software: {
			Valve: {
				Steam: {
					apps: {
						[number]: {
							cloud: {
								last_sync_state: ("synchronized" | "changesincloud")?,
								quota_bytes: number?,
								quota_files: number?,
								used_bytes: number?,
								used_files: number?,
							}?,
							LastPlayed: number?,
							Playtime: number?,
							Playtime2wks: number?,
							LaunchOptions: string?, -- IMPORTANT !
							autocloud: {
								lastlaunch: number,
								lastexit: number,
							}?,
							ViewedSteamPlay: number?,
							BadgeData: string?,
						},
					},
				},
			},
		},
	},
}
type libraryfolders_vdf = {
	libraryfolders: {
		[number]: {
			path: string,
			label: string?,
			contentid: number,
			totalsize: number,
			update_clean_bytes_tally: number,
			time_last_update_corruption: number,
			apps: {
				[number]: number,
			},
		}?,
	},
}

type appmanifest_vdf = {
	AppState: {
		appid: number,
		Universe: number,
		name: string,
		StateFlags: number,
		installdir: string,
		LastUpdated: number,
		LastPlayed: number,
		SizeOnDisk: number,
		StagingSize: number,
		buildid: number,
		LastOwner: number,
		UpdateResult: number?,
		BytesToDownload: number?,
		BytesDownloaded: number?,
		BytesToStage: number?,
		BytesStaged: number?,
		TargetBuildID: number?,
		AutoUpdateBehavior: number,
		AllowOtherDownloadsWhileRunning: number,
		ScheduledAutoUpdate: number,
		InstalledDepots: {
			[number]: {
				manifest: number,
				size: number,
			},
		},
		InstallScripts: {
			[number]: number,
		}?,
		SharedDepots: {
			[number]: number,
		}?,
		UserConfig: {
			language: string?,
			BetaKey: string?,
			platform_override_dest: "linux"?,
			platform_override_source: ("linux" | "windows")?,
		},
		MountedConfig: {
			language: string?,
			BetaKey: string?,
			platform_override_dest: "linux"?,
			platform_override_source: ("linux" | "windows")?, -- IMPORTANT ! (Too bad it seems to never be present in Linux games, and sometimes not in Windows games... :/)
		},
	},
}

type compat_vdf = {
	platform_overrides: {
		[number]: {
			dest: "windows" | "linux",
			src: "windows" | "linux",
		},
	},
}

-- STweaker

-- TODO

-- --------------------------- Script -----------------------------

local Configuration = {}

Configuration.Private = {}
Configuration.Public = {}

-- Public

function Configuration.Public.getSteamConfiguration()
	--[[
		Chapter 1 : We recover the Steam user config so we can get the last active user.
		And also the SteamID3 to access their settings folder.
	]]
	local userConfiguration: loginusers_vdf =
		Configuration.Private.VDFHandler(process.env.HOME .. "/.local/share/Steam/config/loginusers.vdf", "Failed to parse loginusers.vdf file.")
	local activeUserSteamID3 = SteamUtilities.convertToSteamID3(Configuration.Private.getMostRecentUserID(userConfiguration))
	Logging.write("info", "Active user SteamID3 : " .. activeUserSteamID3)
	Logging.separator()

	--[[
		Chapter 2 : We recover the user config to get which games have the tool enabled.

		Note : Error handling should be added for the scenario where the configuration can't be loaded.
	]]
	local localconfig_vdf: localconfig_vdf = Configuration.Private.VDFHandler(
		process.env.HOME .. "/.local/share/Steam/userdata/" .. activeUserSteamID3 .. "/config/localconfig.vdf",
		"Failed to parse active user localconfig.vdf file with SteamID3: " .. activeUserSteamID3
	)
	local userGameConfigurations = localconfig_vdf.UserLocalConfigStore.Software.Valve.Steam.apps
	Logging.write("info", "User game configurations loaded.")
	Logging.separator()

	--[[
		Chapter 2.5 : We recover compat.vdf to know if a game has ever used its Windows version.
		We can't use it directly to get the platform details, as games that have previously used Proton will still be set to "windows" here.
		Logically, a game completely absent from this list is a native Linux game.
	]]
	local compat_vdf: compat_vdf = Configuration.Private.VDFHandler(
		process.env.HOME .. "/.local/share/Steam/userdata/" .. activeUserSteamID3 .. "/config/compat.vdf",
		"Failed to parse compat.vdf file."
	)
	Logging.write("info", "Compatibility data loaded.")
	Logging.separator()

	--[[
		Chapter 3 : We recover the Steam library config to get the list of games.
		We can't use just libraryfolders.vdf to get the game IDs, as Steam seems to not always update it immediately.
	]]
	local libraries: libraryfolders_vdf =
		Configuration.Private.VDFHandler(process.env.HOME .. "/.local/share/Steam/config/libraryfolders.vdf", "Failed to parse libraryfolders.vdf file.")
	Logging.write("info", "Steam libraries loaded.")
	Logging.separator()

	local steamApps = {}
	local steamAppCount = 0

	Async.asyncForEach(libraries.libraryfolders, function(_, library)
		-- We check if the folder exists
		if not fs.metadata(library.path).exists then
			Logging.write("warn", "Steam library " .. library.path .. " doesn't exist. Skipping...")
		else
			Logging.write("data", "Checking library " .. library.path)
			local appManifestFilenames = Filesystem.getFilenamePatternInDirectory(library.path .. "/steamapps", "appmanifest_")

			Async.asyncForEach(appManifestFilenames, function(_, appManifestFilename)
				local appManifestPath: string = library.path .. "/steamapps/" .. appManifestFilename
				local appManifest: appmanifest_vdf = Configuration.Private.VDFHandler(appManifestPath, "Failed to parse " .. appManifestPath .. ".", false)

				Logging.write("info", 'Found "' .. appManifest.AppState.name .. '" (' .. appManifest.AppState.appid .. ")")

				local location = library.path .. "/steamapps/common/" .. appManifest.AppState.installdir

				-- Does the game have launch options set ?
				local configuration = userGameConfigurations[appManifest.AppState.appid]
				local launchOptions
				if configuration then
					launchOptions = configuration.LaunchOptions
				end

				-- Do we know the game's platform
				local osPlatform: ("windows" | "linux")? = appManifest.AppState.MountedConfig.platform_override_source
				if not osPlatform then
					local compat = compat_vdf.platform_overrides[appManifest.AppState.appid]
					-- The app being absent from the compat.vdf list means it can only be a native Linux game
					if not compat then
						osPlatform = "linux"
					else
						-- Gah ! We still don't have the platform... time to check manually.
						Logging.write(
							"warn",
							'Platform not found for "' .. appManifest.AppState.name .. '" (' .. appManifest.AppState.appid .. "). Using manual check..."
						)
						if not Filesystem.directoryContainsLinuxData(location) then
							osPlatform = "windows"
						else
							osPlatform = "linux"
						end
					end
				end

				local steamApp = SteamApp.new(appManifest.AppState.appid, appManifest.AppState.name, library.path, location, osPlatform, launchOptions)
				steamApps[steamApp.appID] = steamApp
				steamAppCount += 1
			end)
		end
	end)

	Logging.write("info", "Found " .. steamAppCount .. " Steam apps.")
	Logging.separator()

	return steamApps
end

-- Private

function Configuration.Private.VDFHandler(filePath: string, errorMessage: string, logging: boolean?): any
	if logging == nil then
		logging = true
	end

	local timeStart
	if logging then
		timeStart = os.clock()
		Logging.write("data", "Parsing VDF file : " .. filePath)
	end

	local result, parsedData = pcall(VDFParser.parseFile, filePath)
	if not result then
		error(errorMessage)
	else
		if logging then
			Logging.write("speed", timeStart)
		end
		return parsedData
	end
end

-- loginuser.vdf

function Configuration.Private.getMostRecentUserID(userData: loginusers_vdf): number
	for id, data in pairs(userData.users) do
		if data.MostRecent == 1 then
			return id
		end
	end
	error("No most recent user found in loginusers.vdf. What ?!")
end

return Configuration.Public
