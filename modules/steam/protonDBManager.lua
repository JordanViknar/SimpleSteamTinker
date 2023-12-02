-- External Modules
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

-- Internal Modules
local logSystem = require("modules.general.logSystem")

local protonDBManager = {}

--[[
	Name : protonDBManager.getAppInfo(appId)
	Description : Retrieves the ProtonDB data for a given app ID.
	Arg 1 : appId (string) : The app ID to retrieve the data for.
	Return : The ProtonDB data for the given app ID.
]]
function protonDBManager.getAppInfo(appId)
	local url = "https://www.protondb.com/api/v1/reports/summaries/"..appId..".json"
    local response = {}

    local success, status, headers = http.request {
        url = url,
        method = "GET",
        sink = ltn12.sink.table(response)
    }

    if success then
        local data = json.decode(table.concat(response)) -- Parse the JSON response
        if data then
			return data
        else
			logSystem.log("error", "Failed to parse JSON response from ProtonDB for app "..appId..".")
            return "Not found"
        end
    else
		logSystem.log("error", "Failed to retrieve ProtonDB data for app "..appId..", with error : "..status..".")
        return "Unavailable"
    end
end

return protonDBManager
