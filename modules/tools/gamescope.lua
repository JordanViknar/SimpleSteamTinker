-- Internal Modules
local toolObject = require("modules.objects.toolObject")

local name = "gamescope"
local type = "executable"
local usage = function(command, config)
	local options = ""

	-- Nested resolution
	if
		config.gamescope.general.resolution.enabled == true
	then
		options = string.format(
			"%s --nested-width %s --nested-height %s --output-width %s --output-height %s",
			options,
			config.gamescope.general.resolution.internal.width,
			config.gamescope.general.resolution.internal.height,
			config.gamescope.general.resolution.external.width,
			config.gamescope.general.resolution.external.height
		)
	end

	-- Frame limit
	if config.gamescope.general.frame_limit.enabled == true then
		options = string.format(
			"%s -r %s -o %s",
			options,
			config.gamescope.general.frame_limit.normal,
			config.gamescope.general.frame_limit.unfocused
		)
	end

	-- Fullscreen
	if config.gamescope.general.fullscreen == true then
		options = options.." -f"
	end
	if config.gamescope.general.borderless == true then
		options = options.." -b"
	end

	-- Filtering
	if config.gamescope.filtering.enabled == true then
		options = string.format(
			"%s --filter %s --sharpness %s",
			options,
			string.lower(config.gamescope.filtering.filter),
			config.gamescope.filtering.sharpness -- gamescope's sharpness is inverted
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
