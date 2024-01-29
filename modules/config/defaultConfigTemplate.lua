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
		obs_gamecapture = {
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
			sharpness = 10; -- Ranges from 0 to 20
		}
	},

	-- Settings exclusive to Windows games
	proton = {
		direct3d = {
			enable_direct3d9 = true; -- Exclusive to Proton GE
			enable_direct3d10 = true;
			enable_direct3d11 = true;
			enable_direct3d12 = true; -- Exclusive to Proton GE
			use_wined3d = false;
		};
		sync = {
			enable_esync = true;
			enable_fsync = true;
		};
		nvidia = {
			enable_nvapi = false;
			hide_nvidia_gpu = false;
		};
		fsr = { -- Exclusive to Proton GE
			enabled = false;
			sharpness = 2; -- Between 0 and 5, 0 = maximum, 5 = minimum
			upscaling_mode = "none"; -- Can be "none", "performance", "balanced", "quality" or "ultra"
			resolution = {
				enabled = false;
				width = 1920;
				height = 1080;
			};
		};
	};
}
