return {
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

	-- Proton
	-- Direct3D
	["Direct3D9_Switch"] = {type= "Switch", setting = "proton.direct3d.enable_direct3d9", os_platform = "Windows"},
	["Direct3D10_Switch"] = {type= "Switch", setting = "proton.direct3d.enable_direct3d10", os_platform = "Windows"},
	["Direct3D11_Switch"] = {type= "Switch", setting = "proton.direct3d.enable_direct3d11", os_platform = "Windows"},
	["Direct3D12_Switch"] = {type= "Switch", setting = "proton.direct3d.enable_direct3d12", os_platform = "Windows"},
	["WineD3D_Switch"] = {type= "Switch", setting = "proton.direct3d.use_wined3d", os_platform = "Windows"},
	-- Sync
	["ESync_Toggle"] = {type= "Toggle", setting = "proton.sync.enable_esync", os_platform = "Windows"},
	["FSync_Toggle"] = {type= "Toggle", setting = "proton.sync.enable_fsync", os_platform = "Windows"},
	-- NVIDIA
	["Hide_NVIDIA_GPU_Switch"] = {type= "Switch", setting = "proton.nvidia.hide_nvidia_gpu", os_platform = "Windows"},
	["Enable_NVAPI_Switch"] = {type= "Switch", setting = "proton.nvidia.enable_nvapi", os_platform = "Windows"},
	-- FSR
	["Wine_FSR_Switch"] = {type= "Switch", setting = "proton.fsr.enabled", os_platform = "Windows"},
	["Wine_FSR_Sharpness_SpinRow"] = {type= "SpinRow", setting = "proton.fsr.sharpness", os_platform = "Windows"},
	["Wine_FSR_Upscaling_Resolution_Mode_ComboRow"] = {type = "ComboRow", setting = "proton.fsr.upscaling_mode", os_platform = "Windows", items = {"None", "Performance", "Balanced", "Quality", "Ultra"}},
	["Wine_FSR_Resolution_Switch"] = {type = "Switch", setting = "proton.fsr.resolution.enabled", os_platform = "Windows"},
	["Wine_FSR_Resolution_External_Width_SpinRow"] = {type= "SpinRow", setting = "proton.fsr.resolution.width", os_platform = "Windows"},
	["Wine_FSR_Resolution_External_Height_SpinRow"] = {type= "SpinRow", setting = "proton.fsr.resolution.height", os_platform = "Windows"}
}
