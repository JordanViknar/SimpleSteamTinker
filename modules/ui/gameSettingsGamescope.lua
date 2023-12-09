-- Internal Modules
local lgiHelper = require("modules.ui.lgiHelper")
local configManager = require("modules.config.configManager")

return function(application, interface, steamGameData, gameSettings)
	-- GameScope Enabled button
	local gamescope_Switch = interface:get_object("gamescope_Switch")
	lgiHelper.connectUtilityToButton(steamGameData.id, gamescope_Switch, "gamescope", gameSettings.gamescope.enabled, "gamescope.enabled")

	-- Resolution
	local gamescope_Resolution_Switch = interface:get_object("gamescope_Resolution_Switch")
	lgiHelper.connectUtilityToButton(steamGameData.id, gamescope_Resolution_Switch, "gamescope", gameSettings.gamescope.general.resolution.enabled, "gamescope.general.resolution.enabled")

	-- Framerate
	local gamescope_Framerate_Switch = interface:get_object("gamescope_Framerate_Switch")
	lgiHelper.connectUtilityToButton(steamGameData.id, gamescope_Framerate_Switch, "gamescope", gameSettings.gamescope.general.frame_limit.enabled, "gamescope.general.frame_limit.enabled")

	-- Filtering
	local gamescope_Filtering_Switch = interface:get_object("gamescope_Filtering_Switch")
	lgiHelper.connectUtilityToButton(steamGameData.id, gamescope_Filtering_Switch, "gamescope", gameSettings.gamescope.filtering.enabled, "gamescope.filtering.enabled")

	-- Borderless
	local gamescope_Borderless_Toggle = interface:get_object("gamescope_Borderless_Toggle")
	lgiHelper.connectUtilityToButton(steamGameData.id, gamescope_Borderless_Toggle, "gamescope", gameSettings.gamescope.general.borderless, "gamescope.general.borderless", "on_toggled")
	-- Fullscreen
	local gamescope_Fullscreen_Toggle = interface:get_object("gamescope_Fullscreen_Toggle")
	lgiHelper.connectUtilityToButton(steamGameData.id, gamescope_Fullscreen_Toggle, "gamescope", gameSettings.gamescope.general.fullscreen, "gamescope.general.fullscreen", "on_toggled")

	-- Settings (done like this in preparation for a major refactor)
	local spinRows = {
		["gamescope.general.resolution.internal.width"] = interface:get_object("gamescope_Resolution_Internal_Width_SpinRow"),
		["gamescope.general.resolution.internal.height"] = interface:get_object("gamescope_Resolution_Internal_Height_SpinRow"),
		["gamescope.general.resolution.external.width"] = interface:get_object("gamescope_Resolution_External_Width_SpinRow"),
		["gamescope.general.resolution.external.height"] = interface:get_object("gamescope_Resolution_External_Height_SpinRow"),
		["gamescope.general.frame_limit.normal"] = interface:get_object("gamescope_Framerate_Normal_SpinRow"),
		["gamescope.general.frame_limit.unfocused"] = interface:get_object("gamescope_Framerate_Unfocused_SpinRow"),
		["gamescope.filtering.sharpness"] = interface:get_object("gamescope_Filtering_Sharpness_SpinRow"),
	}
	for setting, widget in pairs(spinRows) do
		-- Split the setting into keys
		local keys = {}
		for substring in setting:gmatch("[^.]+") do
			keys[#keys + 1] = substring
		end

		-- Modify the table
		local pointer = gameSettings
		for i = 1, #keys - 1 do
			pointer = pointer[keys[i]] or {}
		end

		lgiHelper.removeSignal(widget, "on_changed")

		widget.value = pointer[keys[#keys]]

		lgiHelper.replaceSignal(widget, "on_changed", function()
			configManager.modifyGameConfig(steamGameData.id, setting, math.floor(widget:get_value()))
		end)
	end

	-- Filtering (Ugly)
	local comboRow = interface:get_object("gamescope_Filtering_Filter_ComboRow")
	local model = comboRow:get_model()
	lgiHelper.removeSignal(comboRow, "notify")

	if gameSettings.gamescope.filtering.filter == "Linear" then
		comboRow:set_selected(0)
	elseif gameSettings.gamescope.filtering.filter == "Nearest" then
		comboRow:set_selected(1)
	elseif gameSettings.gamescope.filtering.filter == "FSR" then
		comboRow:set_selected(2)
	elseif gameSettings.gamescope.filtering.filter == "NIS" then
		comboRow:set_selected(3)
	elseif gameSettings.gamescope.filtering.filter == "Pixel" then
		comboRow:set_selected(4)
	end

	lgiHelper.replaceSignal(comboRow, "on_notify", function()
		local setting = model:get_string(comboRow:get_selected())
		configManager.modifyGameConfig(steamGameData.id, "gamescope.filtering.filter", setting)
	end)
end
