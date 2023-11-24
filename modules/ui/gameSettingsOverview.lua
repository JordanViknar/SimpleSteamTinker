-- Internal Modules
local lgiHelper = require("modules.ui.lgiHelper")
local protonDBManager = require("modules.steam.protonDBManager")
local fsUtils = require("modules.general.fsUtils")
local logSystem = require("modules.general.logSystem")
local systemUtils = require("modules.general.systemUtils")

-- External Modules
local lgi = require("lgi")
local Adw = lgi.Adw

return function(app, builder, game)
	--[[
		SIDEBAR
	]]
	-- Set the game icon and name in the sidebar
	builder:get_object("gameSettingsSidebarLabel").label = game.name
	builder:get_object("gameSettingsSidebarIcon").file = game.images.icon

	--[[
		OVERVIEW
	]]
	-- Sets the game image in the overview banner
	builder:get_object("gameBanner"):set_filename(game.images.header)
	-- Sets the game title in the overview area
	builder:get_object("gameTitle").label = game.name

	-- ProtonDB rating
	local protonRating_Label = builder:get_object("protonDBRating_Label")
	protonRating_Label.label = "Loading..."
	protonRating_Label.css_classes = {"dim-label"}
	if game.os_platform == "Windows" then
		-- Coroutine to load the rating : it's done in a coroutine to avoid slowing down the UI.
		local function loadProtonDBrating()
			-- If the game's rating hasn't been retrieved yet, we retrieve it.
			-- The reason why this is done HERE is because it would slow down startup otherwise.
			if game.protondb_data == nil then
				logSystem.log("download", "Loading ProtonDB rating for "..game.name.."...")
				game.protondb_data = protonDBManager.getAppInfo(game.id)
			end

			-- We set the rating label
			if game.rating == "Not found" then
				protonRating_Label.css_classes = {"error"}
			elseif game.rating == "Unavailable" then
				protonRating_Label.css_classes = {"dim-label"}
			else
				-- May later be used for extra CSS classes
			end
			local rating = game.protondb_data["tier"] or game.protondb_data
			-- Set label and capitalize the first letter
			protonRating_Label.label = rating:sub(1, 1):upper()..rating:sub(2)
		end

		coroutine.wrap(loadProtonDBrating)()
	else
		protonRating_Label.label = "Native"
	end

	-- Sets up the game start button
	local gameLaunchButton = builder:get_object("gameLaunchButton")
	lgiHelper.replaceSignal(gameLaunchButton, "on_clicked", function()
		os.execute("xdg-open steam://rungameid/"..game.id.." &> /dev/null")
	end)

	-- Sets up the game's SimpleSteamTinker status
	local gameStatus, gameColor
	if game.status == true then
		gameStatus = "Enabled"
		gameColor = "success"
	elseif game.status == "SteamTinkerLaunch" then
		gameStatus = "SteamTinkerLaunch"
		gameColor = "warning"
	else
		gameStatus = "Disabled"
		gameColor = "error"
	end
	local gameStatus_Label = builder:get_object("gameStatus_Label")
	gameStatus_Label.label = gameStatus
	gameStatus_Label.css_classes = {gameColor}

	-- Sets the game ID in the overview area
	builder:get_object("gameID_Label").label = game.id
	-- Sets up the game ID copy button in the overview area
	local toastSystem = builder:get_object("toastSystem")
	local gameIDCopyButton = builder:get_object("gameID_copyButton")
	lgiHelper.replaceSignal(gameIDCopyButton, "on_clicked", function()
		if systemUtils.copyToClipboard(game.id) then
			toastSystem:add_toast(
				Adw.Toast.new("Game ID copied to clipboard !")
			)
		end
	end)
	-- Sets the game platform in the overview area
	builder:get_object("gamePlatform_Label").label = game.os_platform

	-- Sets the game size in the overview area
	local gameSize_Label = builder:get_object("gameSize_Label")
	gameSize_Label.label = "Loading..."
	if not game.size then
		logSystem.log("fileRead", "Detecting size for "..game.name.."...")
		-- Coroutine to get the game size : it's done in a coroutine to avoid slowing down the app.
		coroutine.wrap(function()
			game.size = fsUtils.sizeToUnit(fsUtils.getSize(game.location))
			gameSize_Label.label = game.size
		end)()
	else
		gameSize_Label.label = game.size
	end

	-- Sets the game folder in the overview area
	builder:get_object("gameLocation_ActionRow").subtitle = game.location
	-- Modifies the button to get to the game's folder
	local gameFolderButton = builder:get_object("gameLocationButton")
	lgiHelper.replaceSignal(gameFolderButton, "on_clicked", function()
		os.execute("xdg-open '"..game.location:gsub("'", "'\\''").."' &> /dev/null")
	end)
end