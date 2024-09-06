local process = require("@lune/process")

local Logging = require("Logging")

local System = {}

--[=[
	Sends a notification using notify-send.
	Currently uses notify-send (again) due to limitations with Lune that should be lifted with FFI support.

	@param title string -- The notification's title.
	@param message string -- The notification's message.
	@param urgency string -- The notification's urgency. Default : nil
	@param transient boolean -- Whether the notification should be transient. Default : false
	@param time number -- The notification's time. Default : nil
	@return nil
]=]
function System.sendNotification(title: string, message: string, urgency: ("normal" | "critical")?, transient: boolean?, time: number?)
	local arguments = {
		title,
		message,
	}
	if transient then
		table.insert(arguments, "-e")
	end

	if urgency then
		table.insert(arguments, "-u")
		table.insert(arguments, urgency)
	end
	if time then
		table.insert(arguments, "-t")
		table.insert(arguments, tostring(time))
	end

	local execution = process.spawn("notify-send", arguments)

	if not execution.ok then
		Logging.write("error", "Unable to send notification : " .. execution.stderr)
	end
end

return System
