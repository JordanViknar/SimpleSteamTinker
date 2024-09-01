local fs = require("@lune/fs")
local Logging = require("Logging")

--[=[
	Utilities for filesystem operations. Mostly a remnant from SimpleSteamTinker.
]=]
local Filesystem = {}

--[=[
	Creates a directory if it doesn't exist, or uses it if it does.

	@param path The path to create or use.
	@return The path to the created or used directory.
]=]
function Filesystem.createOrUseDirectory(path: string): string
	if not fs.isDir(path) then
		Logging.write("debug", "Directory "..path.." not found. Creating it...")
		fs.writeDir(path)
	end
	return path
end

--[=[
	Gets the size of a file or directory. Unimplemented.

	@param path The path to get the size of.
]=]
function Filesystem.getSize(path: string): ()
	--TODO
end

--[=[
	Converts a size in bytes to a human-readable size.
	
	@param size The size to convert.
	@return The human-readable size.
]=]
function Filesystem.sizeToUnit(size: number): string
	local units = {"B", "KB", "MB", "GB", "TB"}

	local unit
	for i = 1, 5 do
		if size > 1024 then
			size = size / 1024
			unit = units[i]
		end
	end

	return string.format("%.2f", size).." "..unit
end

--[=[
	Returns a table containing every filename matching a pattern in a directory.
	
	@param directory The directory to search in.
	@param pattern The pattern to search for.
	@return A table containing every filename matching the pattern.
]=]
function Filesystem.getFilenamePatternInDirectory(directory: string, pattern: string): {string}
	local result = {}

	for _, file in fs.readDir(directory) do
		if file:match(pattern) then
			table.insert(result, file)
		end
	end

	return result
end

return Filesystem
