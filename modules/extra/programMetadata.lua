return {
	name="SimpleSteamTinker",
	description = "A work-in-progress fast, simple and modern Libadwaita alternative to SteamTinkerLaunch.",
	executable="sst",
	icon_name = "simplesteamtinker",
	version="indev",
	developer="JordanViknar",
	url = "https://github.com/JordanViknar/SimpleSteamTinker",
	installdir = os.getenv("SST_SCRIPT_PATH"),
	folders = {
		config = os.getenv("HOME").."/.config/SimpleSteamTinker",
		gamesConfig = os.getenv("HOME").."/.config/SimpleSteamTinker/games",

		storage = os.getenv("HOME").."/.local/share/SimpleSteamTinker",
		cache = os.getenv("HOME").."/.cache/SimpleSteamTinker"
	}
}
