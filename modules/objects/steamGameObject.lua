-- Internal Modules
local fsUtils = require("modules.general.fsUtils")

-- Constants
local steamImagesLocation = os.getenv("HOME").."/.local/share/Steam/appcache/librarycache/"

-- Extra function
local function ifExists(path)
	if fsUtils.exists(path) then
		return path
	else
		return nil
	end
end

-- Object
SteamGame = {
	metatable = {
		__index = SteamGame
	}
}
function SteamGame:new (id, name, library, location)
	-- Current way of detecting if an app is a game or a tool... not the greatest.
	local type = "game"
	local libraryIconPath = steamImagesLocation..id.."_library_600x900.jpg"
	if not fsUtils.exists(libraryIconPath) then
		libraryIconPath = nil
		type = "software"
	end
	if name:find("Proton") then
		type = "proton"
	end

	-- The actual OS detection is in steamConfigProvider.lua instead. This is here because Linux games can have compatdata left over from previously using Proton.
	local protonConfig = {}
	if fsUtils.exists(library.."/steamapps/compatdata/"..id) then
		protonConfig.compatdata = library.."/steamapps/compatdata/"..id
	end

	return setmetatable({
		id = id,
		name = name,
		library = library,
		location = location,
		size = nil, -- Slow, done in UI
		protondb_data = nil, -- VERY slow, done in UI
		type = type,
		os_platform = "Linux", -- Assume Linux first, normally gets reconfigured as Windows later
		proton_config = protonConfig,
		tool_status = false, -- Assume the game is not setup to use the tool, normally gets reconfigured true later
		images = {
			header = ifExists(steamImagesLocation..id.."_header.jpg"),
			icon = ifExists(steamImagesLocation..id.."_icon.jpg"),
			logo = ifExists(steamImagesLocation..id.."_logo.jpg"),
			library = libraryIconPath,
			library_hero = ifExists(steamImagesLocation..id.."_library_hero.jpg"),
			library_hero_blur = ifExists(steamImagesLocation..id.."_library_hero_blur.jpg"),
		}
	}, SteamGame.metatable)
end

return SteamGame
