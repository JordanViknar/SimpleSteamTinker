local fs = require("@lune/fs")

type VDFTable = { [string]: VDFValue }
type VDFValue = string | VDFTable

local function parseVDFData(input: string): VDFTable
	-- Trim function to remove whitespace
	local function trim(s: string): string?
		return s:match("^%s*(.-)%s*$")
	end

	-- Handle escape sequences
	local function parseString(string: string, pos: number): (string, number)
		local result = ""
		local len = #string
		while pos <= len do
			local char = string:sub(pos, pos)
			if char == "\\" then
				pos = pos + 1
				if pos <= len then
					local nextChar = string:sub(pos, pos)
					if nextChar == '"' then
						result = result .. '"'
					elseif nextChar == "\\" then
						result = result .. "\\"
					elseif nextChar == "n" then
						result = result .. "\n"
					elseif nextChar == "t" then
						result = result .. "\t"
					else
						result = result .. "\\" .. nextChar
					end
				end
			elseif char == '"' then
				break
			else
				result = result .. char
			end
			pos = pos + 1
		end
		return result, pos
	end

	-- Parsing logic
	local pos = 1
	local len = #input
	local stack: { VDFValue } = {}
	local currentTable: VDFTable = {}
	local currentKey: string? = nil

	while pos <= len do
		local char = input:sub(pos, pos)

		if char == '"' then
			-- Extract the key or value with escape sequence handling
			pos = pos + 1
			local parsedString
			parsedString, pos = parseString(input, pos)
			parsedString = trim(parsedString) or parsedString
			pos = pos + 1 -- Skip the closing quote

			if currentKey == nil then
				-- It's a key
				currentKey = parsedString
			else
				-- It's a value
				currentTable[currentKey] = parsedString
				currentKey = nil
			end
		elseif char == "{" then
			-- Start a new table
			local newTable: VDFTable = {}
			if currentKey ~= nil then
				currentTable[currentKey] = newTable
				currentKey = nil
			else
				error("Malformed VDF: encountered '{' without a preceding key")
			end
			table.insert(stack, currentTable)
			currentTable = newTable
		elseif char == "}" then
			-- End the current table
			if #stack == 0 then
				error("Malformed VDF: encountered '}' without a matching '{'")
			end

			local data = table.remove(stack)
			if not data or typeof(data) == "string" then
				error("Malformed VDF")
			end
			currentTable = data
		elseif not (char == "\n" or char == "\t" or char == " ") then
			error("Malformed VDF: unexpected character '" .. char .. "'")
		end

		pos = pos + 1
	end

	if #stack > 0 then
		error("Malformed VDF: unclosed '{'")
	end

	return currentTable
end

local function sanitizeVDFTable(input: VDFTable)
	local function convertValue(value: any): any
		if type(value) == "string" then
			-- Check for number values (integers or floats)
			local numberValue = tonumber(value)
			if numberValue ~= nil then
				return numberValue
			end
			-- Check for empty strings
			if value == "" then
				return nil
			end
			-- If it's neither, return the original string
			return value
		elseif type(value) == "table" then
			-- Recursively sanitize nested tables
			return sanitizeVDFTable(value)
		else
			-- Return the value as-is for unsupported types (shouldn't happen in a VDF)
			return value
		end
	end

	local result = {}
	for key, value in pairs(input) do
		result[convertValue(key)] = convertValue(value)
	end

	return result
end


local VDFParser = {}

function VDFParser.parseFile(path: string)
	return VDFParser.parseString(fs.readFile(path))
end

function VDFParser.parseString(input: string)
	return sanitizeVDFTable(parseVDFData(input))
end

return VDFParser
