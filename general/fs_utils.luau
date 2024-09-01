--!strict
local fsUtils = {}

-- Lune Modules
local fs = require("@lune/fs")

-- Internal Modules
local logSystem = require("log_system")

--[[
	Name : function fsUtils.exists(path)
	Description : Checks if a file or directory exists.
	Arg 1 : path (string) : The path to check.
	Return : true if the file or directory exists, false otherwise.
]]
function fsUtils.exists(path: string): boolean
	return fs.metadata(path).exists
end

--[[
	Name : function fsUtils.isDirectory(path)
	Description : Checks if a path is a directory.
	Arg 1 : path (string) : The path to check.
	Return : true if the path is a directory, false otherwise.
]]
function fsUtils.isDirectory(path: string): boolean
	return fs.isDir(path)
end

--[[
	Name : function fsUtils.createOrUseDirectory(path)
	Description : Creates a directory if it doesn't exist, or uses it if it does.
	Arg 1 : path (string) : The path to create or use.
	Return : true if the directory was created or used, false otherwise.
]]
function fsUtils.createOrUseDirectory(path: string): string
	if not fs.isDir(path) then
		logSystem.log("debug", "Directory "..path.." not found. Creating it...")
		fs.writeDir(path)
	end
	return path
end

--[[
	Name : function fsUtils.getSize(path)
	Description : Gets the size of a file or directory.
	Arg 1 : path (string) : The path to get the size of.
	Return : The size of the file or directory.
]]
function fsUtils.getSize(path: string): ()
	-- Can't be implemented for now.
end

--[[ 
	Name : function fsUtils.sizeToUnit(size)
	Description : Converts a size in bytes to a human-readable size.
	Arg 1 : size (number) : The size to convert.
	Return : The human-readable size.
]]
type SizeUnit = "B" | "KB" | "MB" | "GB" | "TB"
function fsUtils.sizeToUnit(size: number): string
	local unit: SizeUnit = "B"
	if size > 1024 then
		size = size / 1024
		unit = "KB"
	end
	if size > 1024 then
		size = size / 1024
		unit = "MB"
	end
	if size > 1024 then
		size = size / 1024
		unit = "GB"
	end
	if size > 1024 then
		size = size / 1024
		unit = "TB"
	end
	return string.format("%.2f", size).." "..unit
end

-- Missing stuff here

--[[
	Name : function fsUtils.getFilenamePatternInDirectory(directory, pattern)
	Description : Returns a table containing every filename matching a pattern in a directory.
	Arg 1 : directory (string) : The directory to search in.
	Arg 2 : pattern (string) : The pattern to search for.
	Return : A table containing every filename matching the pattern.

	Note : Used to for game detection to work around Steam not updating the libraryfolders.vdf file immediately.
]]
function fsUtils.getFilenamePatternInDirectory(directory: string, pattern: string): {string}
	local result = {}

	for _, file in fs.readDir(directory) do
		if file:match(pattern) then
			table.insert(result, file)
		end
	end

	return result
end

return fsUtils