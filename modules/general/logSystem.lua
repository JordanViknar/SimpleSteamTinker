local logSystem = {}

--[[
	Name : local function color(colorId, message)
	Description : Colors a message.
	Arg 1 : colorId (string) : The color's id.
	Arg 2 : message (string) : The message to color.
	Return : The colored message.
]]
local function color(colorId, message)
	local colorList = {
		["red"] = "\27[31m",
		["green"] = "\27[32m",
		["yellow"] = "\27[33m",
		["blue"] = "\27[34m",
		["magenta"] = "\27[35m",
		["cyan"] = "\27[36m",
		["white"] = "\27[37m",
		["grey"] = "\27[90m",
		["orange"] = "\27[91m",
		["reset"] = "\27[0m"
	}

	return colorList[colorId]..message..colorList["reset"]
end

--[[
	Name : function logSystem.log(type, message)
	Description : Logs a message.
	Arg 1 : type (string) : The log type.
	Arg 2 : message (string) : The message to log.
	Return : nil
]]
function logSystem.log(type, message)
	local logReactions = {
		["info"] = function(text)
			print("["..color("blue","Info").."] "..text)
		end,
		["warning"] = function(text)
			print("["..color("yellow","Warning").."] "..color("yellow",text))
		end,
		["error"] = function(text)
			print(color("red","[Error]").." "..color("red",text))
		end,
		["debug"] = function(text)
			print("["..color("grey","Debug").."] "..color("grey",text))
		end,
		["switch"] = function (text)
			print(color("green","[Output Switch] "..text))
			print("--------------------------")
		end,
		["switchEnd"] = function (text)
			print("--------------------------")
		end,
		["download"] = function (text)
			print("["..color("green","Download").."] "..text)
		end,
		["fileRead"] = function (text)
			print("["..color("magenta","Data").."] "..text)
		end,
		["speed"] = function (startTime)
			print("["..color("grey","Speed").."] ".."Done in "..os.clock()-startTime.." seconds.")
		end
	}

	if (logReactions[type]) then
		logReactions[type](message)
	else
		error("Unknown log type : "..type)
	end
end

return logSystem
