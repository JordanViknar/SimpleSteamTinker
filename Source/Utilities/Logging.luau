type LogColor = "red" | "green" | "yellow" | "blue" | "magenta" | "cyan" | "white" | "grey" | "orange" | "reset"
type LogType = "info" | "warning" | "error" | "debug" | "download" | "data" | "speed"

local Logging = {}
Logging.Private = {}
--[=[
	Contains functions for logging to the console.
]=]
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

	local logFunctions = {
		info = function(text)
			print("["..color("blue","Info").."] "..text)
		end,
		warning = function(text)
			print("["..color("yellow","Warning").."] "..color("yellow",text))
		end,
		error = function(text)
			print(color("red","[Error]").." "..color("red",text))
		end,
		debug = function(text)
			print("["..color("grey","Debug").."] "..color("grey",text))
		end,
		download = function (text)
			print("["..color("green","Download").."] "..text)
		end,
		data = function (text)
			print("["..color("magenta","Data").."] "..text)
		end,
		speed = function (startTime)
			print("["..color("grey","Speed").."] ".."Done in "..os.clock()-startTime.." seconds.")
		end
	}
	
	logFunctions[type](message)
end

-- Private

--[=[
	Colors a text.

	@param colorName string -- The color's name.
	@param text string -- The text to color.
	@return string -- The colored text.
]=]
function Logging.Private.colorText(colorName: string, text: string): string 
	local colorList = {
		red = "\27[31m",
		green = "\27[32m",
		yellow = "\27[33m",
		blue = "\27[34m",
		magenta = "\27[35m",
		cyan = "\27[36m",
		white = "\27[37m",
		grey = "\27[90m",
		orange = "\27[91m",
		reset = "\27[0m"
	}
	return colorList[colorName]..text..colorList["reset"]
end

return Logging.Public
