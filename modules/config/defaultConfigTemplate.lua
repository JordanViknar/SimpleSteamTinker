return

{
	config_version = 1;
	steamGameId = nil;

	dgpu = {
		enabled = true;
	};

	-- Miscellaneous
	misc = {
		sdl_wayland = true;
	};

	-- Utilities
	utilities = {
		gamemode = {
			enabled = true;
		},
		mangohud = {
			enabled = false;
		},
		zink = {
			enabled = false;
		},
	},

	-- GameScope
	gamescope = {
		enabled = false;
		general = {
			resolution = {
				enabled = false;
				internal = {
					width = 1280;
					height = 720;
				};
				external = {
					width = 1920;
					height = 1080;
				};
			};
			frame_limit = {
				enabled = false;
				normal = 60;
				unfocused = 5;
			};
			fullscreen = false;
			borderless = false;
		};
		filtering = {
			enabled = false;
			filter = "FSR"; -- "Linear", "Nearest", "FSR", "NIS", "Pixel"
			sharpness = 5; -- Ranges from 0 to 20
		}
	},

	-- Settings exclusive to Windows games
	proton = {
		direct3d = {
			enable_direct3d10 = true;
			enable_direct3d11 = true;
			use_wined3d = false;
		};
		sync = {
			enable_esync = true;
			enable_fsync = true;
			use_winesync = true;
		};
		nvidia = {
			enable_nvapi = true;
			hide_nvidia_gpu = false;
			enable_dlss = true;
		};
		force_large_address_aware = false;
		fsr = {
			enabled = false;
			sharpening = 2;
			upscaling_mode = "none"; -- Can be "none", "performance", "balanced", "quality" or "ultra"
			--[[
			resolution = {
				width = 1920;
				height = 1080;
			};
			]]
		};

		-- These settings are related to Wine in general
		virtual_desktop = {
			enabled = false;
			--[[
			resolution = {
				width = 1920;
				height = 1080;
			};
			]]
		};
	};

	--[[
	-- DXVK
	dxvk = {
		hud = 0;
		loglevel = "none";
		path = nil;
		hud_scale = 1;
		framerate_limit = nil;
		async = false;
		hdr = false;
	}
	]]
}
