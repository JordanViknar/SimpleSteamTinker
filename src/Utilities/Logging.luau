local stdio = require("@lune/stdio")

type LogColor = "black" | "blue" | "cyan" | "green" | "purple" | "red" | "reset" | "white" | "yellow"
type LogType = "info" | "warn" | "error" | "debug" | "data" | "speed" | "special" | "success"

--[=[
	@class Utilities.Logging

	Contains functions for logging to the console.
]=]
local Logging = {}
Logging.Private = {}
Logging.Public = {}

-- Public

--[=[
	Writes a message in the logs.

	@param type string -- The log type.
	@param message string -- The message to log.
	@return nil
]=]
function Logging.Public.write(type: LogType, message: string | number)
	local color = Logging.Private.colorText
	local time = os.date("%H:%M:%S")

	local logFunctions = {
		info = function(text)
			print(time .. " - [" .. color("blue", "Info") .. "] : " .. text)
		end,
		warn = function(text)
			print(time .. " - [" .. color("yellow", "Warn") .. "] : " .. color("yellow", text))
		end,
		error = function(text)
			print(time .. " - " .. color("red", "[Error] : " .. text))
		end,
		debug = function(text)
			print(time .. " - [" .. color("white", "Debug") .. "] : " .. color("white", text))
		end,
		data = function(text)
			print(time .. " - [" .. color("purple", "Data") .. "] : " .. text)
		end,
		speed = function(startTime)
			print(time .. " - [" .. color("white", "Speed") .. "] : " .. "Done in " .. os.clock() - startTime .. " seconds.")
		end,
		success = function(text)
			print(time .. " - [" .. color("green", "Success") .. "] : " .. text)
		end,
		-- Might be used for an easter egg feature in the future...
		special = function(text)
			print(time .. " - [" .. color("red", "!!!!") .. "] : " .. text)
		end,
	}

	logFunctions[type](message)
end

function Logging.Public.separator()
	print("---------------------------------------------------------------------------------------------")
end

-- Private

--[=[
	Colors a text.

	@param colorName string -- The color's name.
	@param text string -- The text to color.
	@return string -- The colored text.
]=]
function Logging.Private.colorText(colorName: LogColor, text: string): string
	return stdio.color(colorName) .. text .. stdio.color("reset")
end

return Logging.Public
