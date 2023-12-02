#!/bin/lua

--[[
	This script should be used after modifying any of the ui_definitions files.
	It will compile the ui_definitions files into ui files that GTK can use.
	If you do not, the modifications you've made to the UI outside of Lua code will not be applied.
	
	This is basically a workaround for LGI not working well with Gtk templates or to assemble widgets together in general right now.
]]

-- Define the list of files to compile
local baseFile = "mainWindow.blp"
local files = {
    [baseFile] = false,
	["overviewPage.blp"] = false,
	["utilitiesPage.blp"] = false,
	["settingsPage.blp"] = false,
	["commandPage.blp"] = false,
	["gamescopePage.blp"] = false,
	["protonPage.blp"] = false,
	["cleanerPage.blp"] = false,
}

-- Add their contents to the list
for file, _ in pairs(files) do
	local f = io.open("ui/definitions/"..file, "r")
	if not f then
		print("Error: Could not open file "..file)
		os.exit(1)
	end
	files[file] = f:read("*all")
	f:close()
end

local function removeUsageLines(content)
	local lines = {}
	for line in content:gmatch("[^\r\n]+") do
		if not line:find("using ") or not line:find(";") then
			table.insert(lines, line)
		end
	end
	return table.concat(lines, "\n")
end

-- Inside the contents of each file, replace comments written like "//[FILENAME]" with the respective content
for file, content in pairs(files) do
	local newContent = {}
	for line in content:gmatch("[^\r\n]+") do

		local fileName = line:match("//%[(.+)%]")
		if fileName then
			local fileContent = files[fileName]
			if fileContent then
				print("Inserting "..fileName.." into "..file..".")
				table.insert(newContent, removeUsageLines(fileContent))
			else
				table.insert(newContent, line)
			end
		else
			table.insert(newContent, line)
		end

	end
	files[file] = table.concat(newContent, "\n")
end

-- Write it into a location
local location = "/tmp/main.blp"
local f = io.open(location, "w")
if not f then
	print("Error: Could not open file "..location)
	os.exit(1)
end
f:write(files[baseFile])
f:close()

-- Make the blueprint with blueprint-compiler
local command = "blueprint-compiler compile "..location.." > ui/main.ui"
print(command)
os.execute(command)
os.remove(location)