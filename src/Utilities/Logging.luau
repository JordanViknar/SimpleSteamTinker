local stdio = require("@lune/stdio")

type LogColor = "black" | "blue" | "cyan" | "green" | "purple" | "red" | "reset" | "white" | "yellow"
type LogType = "info" | "warn" | "error" | "debug" | "data" | "speed" | "special" | "success"

local function color(colorName: LogColor, text: string): string
	return stdio.color(colorName) .. text .. stdio.color("reset")
end

local Logging = {}

function Logging.write(type: LogType, message: string | number)
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

function Logging.separator()
	print("---------------------------------------------------------------------------------------------")
end

return Logging
