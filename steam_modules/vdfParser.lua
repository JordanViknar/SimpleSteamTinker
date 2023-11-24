local vdfParser = {}

--[[
	Name : function vdfParser.printArray(data, indent)
	Description : Prints a table in a human-readable way.
	Arg 1 : data (table) : The table to print.
	Arg 2 : indent (number) : The indentation level. Default : 0
]]
function vdfParser.printArray(data, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)

    for key, value in pairs(data) do
        if type(value) == "table" then
            print(spaces .. key .. ": {")
            vdfParser.printArray(value, indent + 1)
            print(spaces .. "}")
        else
            print(spaces .. key .. ": " .. tostring(value))
        end
    end
end

--[[
	Name : function vdfParser.parseString(input, stopKeyList)
	Description : Parses a VDF string into a table.
	Arg 1 : input (string) : The VDF string to parse.
	Arg 2 : stopKeyList (table) : A list of keys to stop the parsing at. Default : nil
	Return : result (table) : The parsed table.
]]
function vdfParser.parseString(input, stopKeyList)
    local result = {}

    local status = "keyWait"

	-- Temp Values
    local tempKey, tempValue, tempRecursiveInput = "", "", ""

    local indent = 0
    local previousChar = nil

	-- Until we reached the end of the file
    for i = 1, #input do
        local char = input:sub(i, i)

		-- Status :
		-- keyWait : We wait for a key
		-- readingKey : We are reading a key
		-- valueWait : We wait for a value
		-- readingValue : We are reading a value
		-- readingTableValue : We are reading a table value

		-- String management
        if char == '"' and previousChar ~= "\\" then
            if status == "keyWait" then
                status = "readingKey"
            elseif status == "readingKey" then
                status = "valueWait"
            elseif status == "valueWait" then
                status = "readingValue"
            elseif status == "readingValue" then
                result[tempKey] = tempValue
				-- We stop the parsing if we reached the stopKeyList entry
                if stopKeyList and tempKey == stopKeyList[1] then
                    return result
                end
                tempKey = ""
                tempValue = ""
                status = "keyWait"
            elseif status == "readingTableValue" then
                tempRecursiveInput = tempRecursiveInput..char
            end

		-- Subtable management
        elseif char == '{'  and previousChar ~= "\\" and (status == "valueWait" or status == "readingTableValue") then
            if status == "valueWait" then
                status = "readingTableValue"
            elseif status == "readingTableValue" then
                tempRecursiveInput = tempRecursiveInput..char
                indent = indent + 1
            end
        elseif char == '}'  and previousChar ~= "\\" and status == "readingTableValue" then
            if indent == 0 then
                local newStopKeyList = nil
                if stopKeyList then
                    newStopKeyList = {table.unpack(stopKeyList, 2)}
                    if next(newStopKeyList) == nil then
                        newStopKeyList = nil
                    end
                end

                if stopKeyList == nil or stopKeyList[1] == nil or tempKey == stopKeyList[1] then
                    result[tempKey] = vdfParser.parseString(tempRecursiveInput, newStopKeyList)
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
function vdfParser.parseFile(path, stopKeyList, wordsFromLinesToRemove)
	local file = io.open(path, "r")
	if not file then
		error("File not found : "..path)
	end

	local content = file:read("*all")
	file:close()

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
