-- Custom modules
local logSystem = require("general_modules.logSystem")

-- Module
local systemUtils = {}

--[[
	Name : function systemUtils.sendNotification(title, message, urgency, transient, time)
	Description : Sends a notification using notify-send.
	Arg 1 : title (string) : The notification's title.
	Arg 2 : message (string) : The notification's message.
	Arg 3 : urgency (string) : The notification's urgency. Default : nil
	Arg 4 : transient (boolean) : Whether the notification should be transient. Default : false
	Arg 5 : time (number) : The notification's time. Default : nil
	Return : nil
]]
function systemUtils.sendNotification(title, message, urgency, transient, time)
	local command = "notify-send"
	if (transient) then
		command = command.." -e"
	end
	command = string.format('%s "%s" "%s"',
		command,
		title,
		message
	)
	if (urgency) then
		command = command.." -u "..urgency
	end
	if (time) then
		command = command.." -t "..time
	end

	if not os.execute(command) then
		logSystem.log("error", "Unable to send notification using command : "..command)
	end
end

--[[
	Name : function systemUtils.copyToClipboard(text)
	Description : Copies a text to the clipboard using xclip.
	Arg 1 : text (string) : The text to copy.
	Return : true if successful, false otherwise.
]]
function systemUtils.copyToClipboard(text)
	local command = string.format("echo -n %q | xclip -selection clipboard", text)

	if not os.execute(command) then
		logSystem.log("error", "Unable to copy to clipboard using command : "..command)
		return false
	else
		return true
	end
end

--[[
	Name : function systemUtils.isInstalled(command)
	Description : Checks if an command is installed.
	Arg 1 : command (string) : The command to check.
	Return : true if installed, false otherwise.
]]
function systemUtils.isInstalled(command)
	if os.execute("which "..command.." &> /dev/null") then
		return true
	else
		return false
	end
end

return systemUtils
