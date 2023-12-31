-- Custom modules
local logSystem = require("modules.general.logSystem")
local fsUtils = require("modules.general.fsUtils")
local programMetadata = require("modules.extra.programMetadata")

-- External modules
local lgi = require("lgi")
local Notify = lgi.Notify
Notify.init(programMetadata.name)

-- Module
local systemUtils = {}

--[[
	Name : function systemUtils.sendNotification(title, message, urgency, transient, time)
	Description : Sends a notification using notify-send.
	Arg 1 : title (string) : The notification's title.
	Arg 2 : message (string) : The notification's message.
	Arg 3 : type (string) : The notification's type. Used only for icons right now. Can be "warning", "error" or "information".
	Return : nil
]]
function systemUtils.sendNotification(title, message, type)
	-- Set icons
	local icon
	if type == "warning" then
		icon = "dialog-warning-symbolic"
	elseif type == "error" then
		icon = "dialog-error-symbolic"
	else
		icon = "dialog-information"
	end

	local notification = Notify.Notification.new(title, message, icon)
	notification:show()
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
	if command:sub(1, 1) == "/" then
		return fsUtils.exists(command)
	else
		if os.execute("which "..command.." &> /dev/null") then
			return true
		else
			return false
		end
	end
end

return systemUtils
