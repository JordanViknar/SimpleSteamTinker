local process = require("@lune/process")

return {
	name = "STweaks",
	description = "A work-in-progress fast, simple and modern Libadwaita alternative to SteamTinkerLaunch.",
	version = "indev",
	executable = "stweaks",
	folders = {
		config = process.env.HOME .. "/.config/Stweaks",
		gamesConfig = process.env.HOME .. "/.config/Stweaks/Games",
		storage = process.env.HOME .. "/.local/share/Stweaks",
		cache = process.env.HOME .. "/.cache/Stweaks",
	},
}
