return

{
	config_version = 1;
	steamGameId = nil;

	dgpu = {
		enabled = true;
	};

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


	gamescope = {
		enabled = false;
		general = {
			resolution = {
				internal = {
					width = -1;
					height = -1;
				};
				external = {
					width = -1;
					height = -1;
				};
			};
			["frame-limit"] = {
				normal = -1;
				unfocused = -1;
			};
			fullscreen = false;
			borderless = false;
		};
		filtering = {
			sharpness = -1; -- Ranges from 0 to 20 (-1 used when not set)
			filter = "none"; -- "none", "linear", "nearest", "fsr", "nis", "pixel"
		}
	}
}
