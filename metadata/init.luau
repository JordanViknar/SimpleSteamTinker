--!strict
local process = require("@lune/process")

local metadata = {
	name ="SimpleSteamTinker",
	description = "A work-in-progress fast, simple and modern Libadwaita alternative to SteamTinkerLaunch.",
	executable="sst",
	icon_name = "simplesteamtinker",
	version="indev",
	developer="JordanViknar",
	url = "https://github.com/JordanViknar/SimpleSteamTinker",
	folders = {
		config = process.env.HOME.."/.config/SimpleSteamTinker",
		gamesConfig = process.env.HOME.."/.config/SimpleSteamTinker/games",
		storage = process.env.HOME.."/.local/share/SimpleSteamTinker",
		cache = process.env.HOME.."/.cache/SimpleSteamTinker"
	}
}

return metadata
