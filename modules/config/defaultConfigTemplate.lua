return

{
	config_version = 1;
	steamGameId = nil;

	dgpu = {
		enabled = true;
	};

	utilities = {
		gamemode = {
			enabled = false;
		},
		mangohud = {
			enabled = false;
		},
		zink = {
			enabled = false;
		},
	},

--[[
	["gamescope"] = {
		["enabled"] = true;
		["general"] = {
			["resolution"] = {
				["internal"] = "default";
				["external"] = "default";
			};
			["frame-limit"] = {
				["normal"] = -1;
				["unfocused"] = -1;
			};
			["fullscreen"] = false;
			["borderless"] = false;
			["steam-integration"] = false; -- SteamTinkerLaunch UI mentions this
			["force-nested-window-fullscreen"] = false;
			["grab-cursor"] = false;
			["orientation"] = "normal";
		};
		["filtering"] = {
			["sharpness"] = -1; -- Ranges from 0 to 20
			["type"] = "none"; -- "none", "nearest-neighbor", "amd-fsr", "nvidia-img-scaling"
		}
	}
]]
}
