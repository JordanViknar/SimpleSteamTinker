--!strict
local SteamUtils = {}

--[[
	This function checks if the arguments are from Steam or not.
	I suppose this is where non-Steam game support will be added later.
]]
function SteamUtils.isSteamArgs(arguments: {string}): boolean
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

--[[
	Name : function steamUtils.convertToSteamID3(steamID)
	Description : Converts a SteamID64 to a SteamID3
	Arg 1 : string steamID
	Return : string steamID3
]]
type SteamID64_Dec = number
type SteamID3 = number
function SteamUtils.convertToSteamID3(steamID: SteamID64_Dec): SteamID3
	local offset_id = steamID - 76561197960265728
	local account_type = offset_id % 2
	local account_id = math.floor((offset_id - account_type) / 2) + account_type
	-- Check the -1 here in case of SteamID related bug.
	return (account_id * 2) - account_type - 1
end

return SteamUtils
