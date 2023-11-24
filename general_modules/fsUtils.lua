-- External Modules
local lfs = require("lfs")

-- Internal Modules
local logSystem = require("general_modules.logSystem")

-- Module
local fsUtils = {}

--[[
	Name : function fsUtils.exists(path)
	Description : Checks if a file or directory exists.
	Arg 1 : path (string) : The path to check.
	Return : true if the file or directory exists, false otherwise.
]]
function fsUtils.exists(path)
	local attributes, err = lfs.attributes(path)
	if attributes then
		return true
	else
		return false, err
	end
end

--[[
	Name : function fsUtils.createDirectory(path)
	Description : Creates a directory.
	Arg 1 : path (string) : The path to create.
	Return : true if the directory was created, false otherwise.
]]
function fsUtils.createDirectory(path)
	local success, err = lfs.mkdir(path)
	if success then
		return true
	else
		return false, err
	end
end

--[[
	Name : function fsUtils.createOrUseDirectory(path)
	Description : Creates a directory if it doesn't exist, or uses it if it does.
	Arg 1 : path (string) : The path to create or use.
	Return : true if the directory was created or used, false otherwise.
]]
function fsUtils.createOrUseDirectory(path)
	if not fsUtils.exists(path) then
		logSystem.log("debug", "Directory "..path.." not found. Creating it...")
		return fsUtils.createDirectory(path)
	else
		return true
	end
end

--[[
	Name : function fsUtils.getSize(path)
	Description : Gets the size of a file or directory.
	Arg 1 : path (string) : The path to get the size of.
	Return : The size of the file or directory.
]]
function fsUtils.getSize(path)
	local totalSize = 0
	local stack = { path } -- Initialize a stack with the initial path

	while #stack > 0 do
		local currentPath = table.remove(stack) -- Get the last path from the stack

		local attributes = lfs.attributes(currentPath)
		if attributes then
			if attributes.mode == "file" then
				totalSize = totalSize + attributes.size -- Add file size to total size
			elseif attributes.mode == "directory" then
				for file in lfs.dir(currentPath) do
					if file ~= "." and file ~= ".." then
						local filePath = currentPath .. "/" .. file
						table.insert(stack, filePath) -- Add subdirectories to the stack
					end
				end
			end
		end
	end

	return totalSize
end

--[[ 
	Name : function fsUtils.sizeToUnit(size)
	Description : Converts a size in bytes to a human-readable size.
	Arg 1 : size (number) : The size to convert.
	Return : The human-readable size.
]]
function fsUtils.sizeToUnit(size)
	local unit = "B"
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

--[[
	Name : function fsUtils.directoryContainsLinuxData(location)
	Description : Checks if a directory contains Linux data.
	Arg 1 : location (string) : The directory to check.
	Return : true if the directory contains Linux data, false otherwise.

	Note : Used to for game platform detection to work around Steam not cleaning up the compat.vdf file when going back from the Windows version of a game to the Linux version.
	Note 2 : The reason we don't use os.execute(file) is because Steam can get stuck while starting a game for whatever reason.
]]
-- Alternative to using file command
local function checkFileForKeywords(location, file)
	local filepath = location .. "/" .. file

	local fileHandle = io.open(filepath, "r")
	if not fileHandle then
		return false
	end

	local foundKeywords = false

	for line in fileHandle:lines() do
		if line:find("Linux") or line:find("shell") then
			foundKeywords = true
			break
		end
	end

	fileHandle:close()

	return foundKeywords
end

function fsUtils.directoryContainsLinuxData(location)
	for file in lfs.dir(location) do
		if (file:find(".sh") or not file:find(".")) and (file ~= "." or "..") then
			local containsKeywords = checkFileForKeywords(location, file)
			if containsKeywords then
				return true
			end
		end
	end

	return false
end

--[[
	Name : function fsUtils.getFilenamePatternInDirectory(directory, pattern)
	Description : Returns a table containing every filename matching a pattern in a directory.
	Arg 1 : directory (string) : The directory to search in.
	Arg 2 : pattern (string) : The pattern to search for.
	Return : A table containing every filename matching the pattern.

	Note : Used to for game detection to work around Steam not updating the libraryfolders.vdf file immediately.
]]
function fsUtils.getFilenamePatternInDirectory(directory, pattern)
	local result = {}

	for file in lfs.dir(directory) do
		if file:match(pattern) then
			table.insert(result, file)
		end
	end

	return result
end

return fsUtils
