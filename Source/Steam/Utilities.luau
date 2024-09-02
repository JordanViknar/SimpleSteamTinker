--!strict
local process = require("@lune/process")

--[=[
	Minor Steam-related helper functions.
]=]
local Utilities = {}

--[=[
	Checks if the arguments are from Steam or not.
	Non-Steam game support later on will probably necessitate changes.

	@return If the program was launched from Steam.
]=]
function Utilities.isSteamLaunch(): boolean
	local arguments = process.args

	if (
		--arguments[1] == process.env.HOME.."/.local/share/Steam/ubuntu12_32/reaper" and
		arguments[2] == "SteamLaunch" and
		arguments[3]:match("AppId=%d+") and
		arguments[4] == "--" and
		--arguments[5] == process.env.HOME.."/.local/share/Steam/ubuntu12_32/steam-launch-wrapper" and
		arguments[6] == "--"
	) then
		return true
	else
		return false
	end
end

--[=[
	Converts SteamID64 to SteamID3.
]=]
function Utilities.convertToSteamID3(steamID: number): number
	local offset_id = steamID - 76561197960265728
	local account_type = offset_id % 2
	local account_id = math.floor((offset_id - account_type) / 2) + account_type
	
	-- The -1 is meant to be a fix, but could also cause bugs by itself. Keep an eye out.
	return (account_id * 2) - account_type - 1
end

return Utilities
