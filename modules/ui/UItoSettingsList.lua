local UIElements = {
	-- Settings
	["dGPU_Switch"] = {type= "Switch", tool = "switcherooctl", setting = "dgpu.enabled"},
	["SDL_Wayland_Switch"] = {type= "Switch", setting = "misc.sdl_wayland", os_platform = "Linux"},

	-- Utilities
	["gamemode_Switch"] = {type= "Switch", tool = "gamemoderun", setting = "utilities.gamemode.enabled"},
	["mangohud_Switch"] = {type= "Switch", tool = "mangohud", setting = "utilities.mangohud.enabled"},
	["zink_Switch"] = {type= "Switch", tool = "/usr/lib/dri/zink_dri.so", setting = "utilities.zink.enabled"},

	-- Gamescope
	["gamescope_Switch"] = {type= "Switch", tool = "gamescope", setting = "gamescope.enabled"},
	-- Resolution
	["gamescope_Resolution_Switch"] = {type= "Switch", tool = "gamescope", setting = "gamescope.general.resolution.enabled"},
	["gamescope_Resolution_Internal_Width_SpinRow"] = {type= "SpinRow", tool = "gamescope", setting = "gamescope.general.resolution.internal.width"},
	["gamescope_Resolution_Internal_Height_SpinRow"] = {type= "SpinRow", tool = "gamescope", setting = "gamescope.general.resolution.internal.height"},
	["gamescope_Resolution_External_Width_SpinRow"] = {type= "SpinRow", tool = "gamescope", setting = "gamescope.general.resolution.external.width"},
	["gamescope_Resolution_External_Height_SpinRow"] = {type= "SpinRow", tool = "gamescope", setting = "gamescope.general.resolution.external.height"},
	-- Framerate
	["gamescope_Framerate_Switch"] = {type= "Switch", tool = "gamescope", setting = "gamescope.general.frame_limit.enabled"},
	["gamescope_Framerate_Normal_SpinRow"] = {type= "SpinRow", tool = "gamescope", setting = "gamescope.general.frame_limit.normal"},
	["gamescope_Framerate_Unfocused_SpinRow"] = {type= "SpinRow", tool = "gamescope", setting = "gamescope.general.frame_limit.unfocused"},
	-- Filtering
	["gamescope_Filtering_Switch"] = {type= "Switch", tool = "gamescope", setting = "gamescope.filtering.enabled"},
	["gamescope_Filtering_Sharpness_SpinRow"] = {type= "SpinRow", tool = "gamescope", setting = "gamescope.filtering.sharpness"},
	["gamescope_Filtering_Filter_ComboRow"] = {type= "ComboRow", tool = "gamescope", setting = "gamescope.filtering.filter", items = {"Linear","Nearest","FSR","NIS","Pixel"}},
	-- Extras
	["gamescope_Borderless_Toggle"] = {type= "Toggle", tool = "gamescope", setting = "gamescope.general.borderless"},
	["gamescope_Fullscreen_Toggle"] = {type= "Toggle", tool = "gamescope", setting = "gamescope.general.fullscreen"},
}

return UIElements