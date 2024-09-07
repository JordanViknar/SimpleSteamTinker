local process = require("@lune/process")

local Logging = require("Logging")

local System = {}

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
