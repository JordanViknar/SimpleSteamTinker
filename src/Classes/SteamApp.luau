local fs = require("@lune/fs")
local process = require("@lune/process")

local Metadata = require("../Metadata")

local SteamApp = {}

SteamApp.Interface = {}
SteamApp.Prototype = {}

function SteamApp.Interface.new(
	appID: number,
	name: string,
	library: string,
	location: string,
	platform: ("windows" | "linux")?,
	launchArguments: string?
): SteamApp
	-- Is the app configured to use STweaks ?
	local tweaksEnabled = false
	if launchArguments and launchArguments:find(Metadata.executable .. " ") then
		tweaksEnabled = true
	end

	-- Does the app manifest specify the platform ?
	-- Could be simplified
	local osPlatform: ("Windows" | "Linux")?
	if platform == "windows" then
		osPlatform = "Windows"
	elseif platform == "linux" then
		osPlatform = "Linux"
	end

	-- What type is the app ?
	-- Current way of detecting if an app is a game or a tool... not the greatest.
	local type: "Game" | "Other" | "Proton" = "Game"
	if not fs.metadata(process.env.HOME .. "/.local/share/Steam/appcache/librarycache/" .. appID .. "_library_600x900.jpg").exists then
		type = "Other"
		if name:find("Proton") then
			type = "Proton"
		end
	end

	-- We return the object
	return {
		appID = appID,
		name = name,
		library = library,
		location = location,
		size = nil,
		protonDBData = nil,
		type = type,
		osPlatform = osPlatform,
		protonConfig = nil,
		tweaksEnabled = tweaksEnabled,
	}
end

export type SteamApp = {
	appID: number,
	name: string,
	tweaksEnabled: boolean?,
	library: string,
	location: string,
	type: "Game" | "Other" | "Proton",
	osPlatform: ("Windows" | "Linux")?,
	size: number?, -- Slow, done in UI (Currently unused)
	protonDBData: { any }?, -- Slow, done in UI (Currently unused)
	protonConfig: ProtonConfig?, -- (Currently unused)
}

type ProtonConfig = {
	compatdata_path: string,
	version: string?, -- Another file needs to be checked for this information, currently unused
}

return SteamApp.Interface
