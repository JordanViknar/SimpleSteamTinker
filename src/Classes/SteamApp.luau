local process = require("@lune/process")
local steamImageLocation = process.env.HOME.."/.local/share/Steam/appcache/librarycache/"

local SteamApp = {}

SteamApp.Interface = {}
SteamApp.Object = {}

function SteamApp.Interface.new()

end

export type SteamApp = typeof(SteamApp.Object) & {
	id: number,
	name: string,
	library: string,
	location: string,
	size: number?, -- Slow, done in UI (Currently unused)
	protonDBData: {any}? -- Slow, done in UI (Currently unused)
}

return SteamApp.Interface