local SteamApp = require("@Classes/SteamApp")

export type GameConfiguration = {
	appID : number,
	version : number,

	settings : {
		dgpu : boolean,
		zink : boolean,
		sdl_wayland : boolean
	},

	utilities : {
		gamemode : boolean,
		mangohud : {
			enabled : boolean,
		},
		gamescope : {
			enabled : boolean,
			general : {
				resolution : {
					enabled : boolean;
					internal : {
						width : number,
						height : number,
					},
					external : {
						width : number,
						height : number,
					},
				},
				frame_limit : {
					enabled : boolean,
					normal : number,
					unfocused : number,
				},
				fullscreen : boolean,
				borderless : boolean
			},
			filtering : {
				enabled : boolean,
				filter : "Linear" | "Nearest" | "FSR" | "NIS" | "Pixel",
				sharpness : number,
			}
		},
	}
}

local Default = {}

function Default.getDefaultGameConfiguration(appData : SteamApp.SteamApp) : GameConfiguration
	return {
		appID = appData.appID,
		version = 1,
	
		settings = {
			dgpu = true,
			zink = false,
			sdl_wayland = true
		},

		utilities = {
			gamemode = true,
			mangohud = {
				enabled = true,
			},
			gamescope = {
				enabled = false,
				general = {
					resolution = {
						enabled = false,
						internal = {
							width = 1280,
							height = 720,
						},
						external = {
							width = 1920,
							height = 1080,
						},
					},
					frame_limit = {
						enabled = false,
						normal = 60,
						unfocused = 5,
					},
					fullscreen = false,
					borderless = false
				},
				filtering = {
					enabled = false,
					filter = "FSR",
					sharpness = 5,
				}
			},
		}
	}
end

return Default
