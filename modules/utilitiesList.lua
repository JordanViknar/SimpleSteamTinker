return function (gameConfig)
	return

	-- Executables are ordered by priority (first only applies to the game, last applies to the whole sequence)

	{
		{require("modules.tools.zink"),gameConfig.utilities.zink.enabled,"gameConfig.utilities.zink.enabled"},
		{require("modules.tools.gamescope"),gameConfig.gamescope.enabled,"gameConfig.gamescope.enabled"},
		{require("modules.tools.switcherooctl"),gameConfig.dgpu.enabled,"gameConfig.dgpu.enabled"},
		{require("modules.tools.mangohud"),gameConfig.utilities.mangohud.enabled,"gameConfig.utilities.mangohud.enabled"},
		{require("modules.tools.gamemode"),gameConfig.utilities.gamemode.enabled,"gameConfig.utilities.gamemode.enabled"}
	}

end
