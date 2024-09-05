local process = require("@lune/process")

--[=[
	@class Utilities

	Minor Steam-related helper functions.
]=]
local Utilities = {}

--[=[
	Checks if the arguments are from Steam or not.
	Non-Steam game support later on will probably necessitate changes.

	@return number -- Returns the launched AppID if the arguments are from Steam, otherwise nil.
]=]
function Utilities.isSteamLaunch(): number?
	local appIDArgumentIndex
	for index, argument in ipairs(process.args) do
		-- Locate the SteamLaunch argument, our AppID will be the next argument.
		if argument == "SteamLaunch" then
			appIDArgumentIndex = index + 1
			break
		end
	end

	if appIDArgumentIndex then
		return tonumber(process.args[appIDArgumentIndex]:match("AppId=(%d+)"))
	else
		return nil
	end
end

--[=[
	Converts SteamID64 to SteamID3.

	@param steamID64 number -- The SteamID64 to convert.
	@return number -- Returns the corresponding SteamID3.
]=]
function Utilities.convertToSteamID3(steamID64: number): number
	local offset_id = steamID64 - 76561197960265728
	local account_type = offset_id % 2
	local account_id = math.floor((offset_id - account_type) / 2) + account_type

	-- The -1 is meant to be a fix, but could also cause bugs by itself. Keep an eye out.
	return (account_id * 2) - account_type - 1
end

return Utilities
