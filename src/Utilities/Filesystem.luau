local fs = require("@lune/fs")
local process = require("@lune/process")

local Logging = require("./Logging")

local Filesystem = {}

function Filesystem.createOrUseDirectory(path: string): string
	if not fs.isDir(path) then
		Logging.write("debug", "Directory " .. path .. " not found. Creating it...")
		fs.writeDir(path)
	end
	return path
end

function Filesystem.getSize(path: string): number
	path = path:gsub("'", "'\\''")

	local handle = process.spawn("du", { "-sb", path })

	if not handle.ok then
		error("Failed to get size of path " .. path .. ": " .. handle.stderr)
	end

	local result = tonumber(handle.stdout:match("^(%d+)")) -- Grab only the number
	if not result then
		error("Failed to parse size for output (" .. handle.stdout .. ")")
	else
		return result
	end
end

function Filesystem.sizeToUnit(size: number): string
	local units = { "B", "KB", "MB", "GB", "TB" }
	local unit = units[1] -- Default to "B" (bytes)

	for i = 2, #units do
		if size >= 1024 then
			size = size / 1024
			unit = units[i]
		else
			break
		end
	end

	return string.format("%.2f", size) .. " " .. unit
end

function Filesystem.getFilenamePatternInDirectory(directory: string, pattern: string): { string }
	local result = {}

	for _, file in fs.readDir(directory) do
		if file:match(pattern) then
			table.insert(result, file)
		end
	end

	return result
end

function Filesystem.directoryContainsLinuxData(path: string): boolean
	local files = fs.readDir(path)
	for _, file in ipairs(files) do
		if not fs.isDir(path) and (file:find(".sh") or not file:find(".")) then
			file = path .. "/" .. file

			Logging.write("data", "Checking file " .. file)
			local contents = fs.readFile(file)

			if contents:find("Linux") or contents:find("shell") then
				return true
			end
		end
	end
	return false
end

return Filesystem
