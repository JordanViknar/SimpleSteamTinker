-- Internal Modules
local toolObject = require("modules.objects.toolObject")

local name = "gamescope"
local type = "executable"
local usage = function(command, config)
	local options = ""

	-- Nested resolution
	if
		config.gamescope.general.resolution.internal.width ~= -1
		and
		config.gamescope.general.resolution.internal.height ~= -1
	then
		options = string.format(
			"%s --nested-width %s --nested-height %s",
			options,
			config.gamescope.general.resolution.internal.width,
			config.gamescope.general.resolution.internal.height
		)
	end

	-- External resolution
	if
		config.gamescope.general.resolution.external.width ~= -1
		and
		config.gamescope.general.resolution.external.height ~= -1
	then
		options = string.format(
			"%s --output-width %s --output-height %s",
			options,
			config.gamescope.general.resolution.external.width,
			config.gamescope.general.resolution.external.height
		)
	end

	-- Frame limit
	if config.gamescope.general["frame-limit"].normal ~= -1 then
		options = string.format(
			"%s -r %s",
			options,
			config.gamescope.general["frame-limit"].normal
		)
	end
	if config.gamescope.general["frame-limit"].unfocused ~= -1 then
		options = string.format(
			"%s -o %s",
			options,
			config.gamescope.general["frame-limit"].unfocused
		)
	end

	-- Fullscreen
	if config.gamescope.general.fullscreen == true then
		options = options.." -f"
	end

	-- Borderless
	if config.gamescope.general.borderless == true then
		options = options.." -b"
	end

	-- Filtering
	if config.gamescope.filtering.sharpness ~= -1 then
		options = string.format(
			"%s --sharpness %s",
			options,
			config.gamescope.filtering.sharpness
		)
	end
	if config.gamescope.filtering.filter ~= nil then
		options = string.format(
			"%s --filter %s",
			options,
			config.gamescope.filtering.filter
		)
	end

	-- The command
	return string.format(
		"gamescope %s %s",
		options,
		command
	)
end

return toolObject:new(name, type, usage)
