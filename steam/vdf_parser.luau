--!nocheck
--Note : Temporary

local vdfParser = {}

-- Lune Modules
local fs = require("@lune/fs")

--[[
	Name : function vdfParser.parseString(input, stopKeyList)
	Description : Parses a VDF string into a table.
	Arg 1 : input (string) : The VDF string to parse.
	Arg 2 : stopKeyList (table) : A list of keys to stop the parsing at. Default : nil
	Return : result (table) : The parsed table.
]]

-- Status :
-- keyWait : We wait for a key
-- readingKey : We are reading a key
-- valueWait : We wait for a value
-- readingValue : We are reading a value
-- readingTableValue : We are reading a table value
type ReadStatus = "keyWait" | "readingKey" | "valueWait" | "readingTableValue" | "readingValue"

function vdfParser.parseString(input, stopKeyList: {string}?): {[string]: any}
	local result = {}

	local status: ReadStatus = "keyWait"

	-- Temp Values
	local tempKey: string, tempValue: string, tempRecursiveInput: string = "", "", ""

	local indent: number = 0
	local previousChar: string = nil

	-- Until we reached the end of the file
	for i = 1, #input do
		local char = input:sub(i, i)

		-- String key/value management
		if char == '"' and previousChar ~= "\\" then
			if status == "keyWait" then
				-- We reached the key and start reading it.
				status = "readingKey"
			elseif status == "readingKey" then
				-- We finished reading the key and are now waiting for the value.
				status = "valueWait"
			elseif status == "valueWait" then
				-- We begin reading the value.
				status = "readingValue"
			elseif status == "readingValue" then
				-- We finished reading the value.

				-- Convert value into extra, more practical types
				local actualValue: any
				if tempValue == "0" then actualValue = false
				elseif tempValue == "1" then actualValue = true
				elseif tonumber(tempValue) then actualValue = tonumber(tempValue)
				else actualValue = tempValue end

				-- Same for key
				local actualKey: any
				if tonumber(tempKey) then actualKey = tonumber(tempKey)
				else actualKey = tempKey end

				result[actualKey] = actualValue

				-- We stop the parsing if we reached the stopKeyList entry
				if stopKeyList and tempKey == stopKeyList[1] then
					return result
				end

				tempKey = ""
				tempValue = ""
				status = "keyWait"
			elseif status == "readingTableValue" then
				-- We are currently reading a table. Not stopping until we reached its end.
				tempRecursiveInput = tempRecursiveInput..char
			end

		-- Subtable management

		-- We reach the beginning of a table.
		elseif char == '{'  and previousChar ~= "\\" and (status == "valueWait" or status == "readingTableValue") then
			if status == "valueWait" then
				status = "readingTableValue"
			elseif status == "readingTableValue" then
				tempRecursiveInput = tempRecursiveInput..char
				indent = indent + 1
			end
		
		-- We reach the end of a table.
		elseif char == '}'  and previousChar ~= "\\" and (status == "readingTableValue") then
			if indent == 0 then
				local newStopKeyList = nil
				if stopKeyList then
					newStopKeyList = {table.unpack(stopKeyList, 2)}
					if next(newStopKeyList) == nil then
						newStopKeyList = nil
					end
				end

				if stopKeyList == nil or stopKeyList[1] == nil or tempKey == stopKeyList[1] then
					local actualKey: any
					if tonumber(tempKey) then actualKey = tonumber(tempKey)
					else actualKey = tempKey end
					result[actualKey] = vdfParser.parseString(tempRecursiveInput, newStopKeyList)
				end

				if stopKeyList and tempKey == stopKeyList[1] then
					return result
				end

				tempKey = ""
				tempValue = ""
				tempRecursiveInput = ""
				status = "keyWait"
			else
				tempRecursiveInput = tempRecursiveInput..char
				indent = indent - 1
			end

		-- While reading a key
		elseif status == "readingKey" then
			tempKey = tempKey..char
		
		-- While reading a value
		elseif status == "readingValue" and (stopKeyList == nil or stopKeyList[1] == nil or tempKey == stopKeyList[1]) then
			tempValue = tempValue..char
		
		-- While reading a table value, before sending it through the function again to parse it
		elseif status == "readingTableValue" and (stopKeyList == nil or stopKeyList[1] == nil or tempKey == stopKeyList[1]) then
			tempRecursiveInput = tempRecursiveInput..char
		end

		previousChar = char
	end

	return result
end

--[[
	Name : function vdfParser.parseFile(path, stopKeyList, wordsFromLinesToRemove)
	Description : Parses a VDF file into a table.
	Arg 1 : path (string) : The path to the file to parse.
	Arg 2 : stopKeyList (table) : A list of keys to stop the parsing at. Default : nil
	Arg 3 : wordsFromLinesToRemove (table) : A list of words that, if found in a line, will remove the line. Default : nil
	Return : result (table) : The parsed table.

	Note : Arg 2 and Arg 3 are critical for optimization in big files. Do not hesitate to use them.
	Results such as going from 0.5 seconds to 0.04 seconds are possible.
]]
function vdfParser.parseFile(path: string, stopKeyList: {string}?, wordsFromLinesToRemove: {string}?): {[string]: any}
	local content = fs.readFile(path)

	-- Remove every line that contains a word from wordsFromLinesToRemove
	if wordsFromLinesToRemove then
		local lines = {}
		for line in content:gmatch("[^\r\n]+") do
			local removeLine = false
			for _, word in pairs(wordsFromLinesToRemove) do
				if line:find(word) then
					removeLine = true
					break
				end
			end
			if not removeLine then
				table.insert(lines, line)
			end
		end
		content = table.concat(lines, "\n")
	end

	return vdfParser.parseString(content, stopKeyList)
end

return vdfParser