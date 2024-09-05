local fs = require("@lune/fs")

--[=[
	Contains functions for parsing VDF files and strings.
	Lune does not support VDF files natively.
]=]
local VDFParser = {}

VDFParser.Private = {}
VDFParser.Public = {}

-- ---------------------------------- Public

--[=[
	Parses a VDF file into a table.

	@param path string -- The path to the file.
	@return The parsed file if successful.
]=]
function VDFParser.Public.parseFile(path: string)
	return VDFParser.Public.parseString(fs.readFile(path))
end

--[=[
	Parses a VDF string into a table.

	@param input string -- The VDF string to parse.
	@return The parsed table if successful.
]=]
function VDFParser.Public.parseString(input: string)
	return VDFParser.Private.sanitize(VDFParser.Private.parse(input))
end

-- ---------------------------------- Private

type VDFTable = { [string]: VDFValue }
type VDFValue = string | VDFTable

--[=[
	Parses a VDF string into a table. Private side of the parser.

	@param input The VDF string to parse.
	@return The parsed table if successful.
]=]
function VDFParser.Private.parse(input: string): VDFTable
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

--[=[
	Sanitizes a VDF table by converting string values to their proper types.

	@param input -- The VDF table to sanitize.
	@return The sanitized table.
]=]
function VDFParser.Private.sanitize(input: VDFTable)
	local result = {}

	for key, value in pairs(input) do
		result[VDFParser.Private.convertValue(key)] = VDFParser.Private.convertValue(value)
	end

	return result
end

--[=[
	Converts a VDF value to its proper type.

	@param value -- The value to convert.
	@return The converted value.
]=]
function VDFParser.Private.convertValue(value: any): any
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
		return VDFParser.Private.sanitize(value)
	else
		-- Return the value as-is for unsupported types (shouldn't happen in a VDF)
		return value
	end
end

return VDFParser.Public
