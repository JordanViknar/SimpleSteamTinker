local steamUtils = {}

--[[
	This function checks if the arguments are from Steam or not.
	I suppose this is where non-Steam game support will be added later.
]]
function steamUtils.isSteamArgs(arguments)
	if arguments[7] ~= nil and arguments[7]:find("steamtinkerlaunch") then
		return "steamtinkerlaunch"
	elseif (
		--arguments[1] == os.getenv("HOME").."/.local/share/Steam/ubuntu12_32/reaper" and
		arguments[2] == "SteamLaunch" and
		arguments[3]:match("AppId=%d+") and
		arguments[4] == "--" and
		--arguments[5] == os.getenv("HOME").."/.local/share/Steam/ubuntu12_32/steam-launch-wrapper" and
		arguments[6] == "--"
	) then
		return "steamGame"
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
function steamUtils.convertToSteamID3(steamID)
	local id_str = tostring(steamID)

	if tonumber(id_str) then
		local offset_id = tonumber(id_str) - 76561197960265728
		local account_type = offset_id % 2
		local account_id = math.floor((offset_id - account_type) / 2) + account_type

		return (account_id * 2) - account_type
	else
		error("Unable to decode SteamID : "..id_str)
	end
end

return steamUtils
