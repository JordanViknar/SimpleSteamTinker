-- Internal Modules
local lgiHelper = require("modules.ui.lgiHelper")
local protonDBManager = require("modules.steam.protonDBManager")
local fsUtils = require("modules.general.fsUtils")
local logSystem = require("modules.general.logSystem")
local systemUtils = require("modules.general.systemUtils")

-- External Modules
local lgi = require("lgi")
local Adw = lgi.Adw
local Gio = lgi.Gio

return function(application, interface, steamGameData)
	--[[
		SIDEBAR
	]]
	-- Set the game banner in the sidebar
	interface:get_object("Sidebar_Banner"):set_filename(steamGameData.images.header)

	--[[
		OVERVIEW
	]]
	-- Sets the game image in the overview area
	interface:get_object("Overview_Picture"):set_filename(steamGameData.images.library)
	-- Sets the game title in the overview area
	interface:get_object("gameTitle").label = steamGameData.name

	-- ProtonDB rating
	local protonRating_Label = interface:get_object("protonDBRating_Label")
	protonRating_Label.label = "Loading..."
	protonRating_Label.css_classes = {"dim-label"}
	if steamGameData.os_platform == "Windows" then

		local function loadProtonDBrating()
			-- If the game's rating hasn't been retrieved yet, we retrieve it.
			-- The reason why this is done HERE is because it would slow down startup otherwise.
			if steamGameData.protondb_data == nil then
				logSystem.log("download", "Loading ProtonDB rating for "..steamGameData.name.."...")
				steamGameData.protondb_data = protonDBManager.getAppInfo(steamGameData.id)
			end

			-- We set the rating label
			if steamGameData.protondb_data == "Not found" then
				protonRating_Label.css_classes = {"error"}
			elseif steamGameData.protondb_data == "Unavailable" then
				protonRating_Label.css_classes = {"warning"}
			elseif steamGameData.protondb_data["tier"] == "platinum" then
				protonRating_Label.css_classes = {"success"}
			elseif steamGameData.protondb_data["tier"] == "silver" or "gold" then
				protonRating_Label.css_classes = {"warning"}
			else
				protonRating_Label.css_classes = {"error"}
			end
			local rating = steamGameData.protondb_data["tier"] or steamGameData.protondb_data
			-- Set label and capitalize the first letter
			protonRating_Label.label = rating:sub(1, 1):upper()..rating:sub(2)
		end
		Gio.Async.start(loadProtonDBrating)()

	else
		protonRating_Label.label = "Native"
		protonRating_Label.css_classes = {"success"}
	end

	-- Sets up the game start button
	local gameLaunchButton = interface:get_object("gameLaunchButton")
	lgiHelper.replaceSignal(gameLaunchButton, "on_clicked", function()
		os.execute("xdg-open steam://rungameid/"..steamGameData.id.." &> /dev/null")
	end)

	-- Sets up the game's SimpleSteamTinker status
	local gameStatus, gameColor
	if steamGameData.status == true then
		gameStatus = "Enabled"
		gameColor = "success"
	elseif steamGameData.status == "SteamTinkerLaunch" then
		gameStatus = "SteamTinkerLaunch"
		gameColor = "warning"
	else
		gameStatus = "Disabled"
		gameColor = "error"
	end
	local gameStatus_Label = interface:get_object("gameStatus_Label")
	gameStatus_Label.label = gameStatus
	gameStatus_Label.css_classes = {gameColor}

	-- Sets the game ID in the overview area
	interface:get_object("gameID_Label").label = steamGameData.id
	-- Sets up the game ID copy button in the overview area
	local toastSystem = interface:get_object("toastSystem")
	local gameIDCopyButton = interface:get_object("gameID_copyButton")
	lgiHelper.replaceSignal(gameIDCopyButton, "on_clicked", function()
		if systemUtils.copyToClipboard(steamGameData.id) then
			toastSystem:add_toast(
				Adw.Toast.new("Game ID copied to clipboard !")
			)
		end
	end)
	-- Sets the game platform in the overview area
	interface:get_object("gamePlatform_Label").label = steamGameData.os_platform

	-- Sets the game size in the overview area
	local gameSize_Label = interface:get_object("gameSize_Label")
	gameSize_Label.label = "Loading..."
	if not steamGameData.size then
		logSystem.log("fileRead", "Detecting size for "..steamGameData.name.."...")

		local function insertGameSize()
			steamGameData.size = fsUtils.sizeToUnit(fsUtils.getSize(steamGameData.location))
			gameSize_Label.label = steamGameData.size
		end
		Gio.Async.start(insertGameSize)()

	else
		gameSize_Label.label = steamGameData.size
	end

	-- Sets the game folder in the overview area
	interface:get_object("gameLocation_ActionRow").subtitle = steamGameData.location
	-- Modifies the button to get to the game's folder
	local gameFolderButton = interface:get_object("gameLocationButton")
	lgiHelper.replaceSignal(gameFolderButton, "on_clicked", function()
		os.execute("xdg-open '"..steamGameData.location:gsub("'", "'\\''").."' &> /dev/null")
	end)

	-- Sets the compatdata folder in the overview area
	local gameCompatdata_ActionRow = interface:get_object("gameCompatdata_ActionRow")
	if steamGameData.os_platform == "Windows" then
		gameCompatdata_ActionRow.visible = true
		if steamGameData.proton_config.compatdata then
			gameCompatdata_ActionRow:set_sensitive(true)
			gameCompatdata_ActionRow.subtitle = steamGameData.proton_config.compatdata
			-- Modifies the button to get to the game's compatdata folder
			lgiHelper.replaceSignal(interface:get_object("gameCompatdataButton"), "on_clicked", function()
				os.execute("xdg-open '"..steamGameData.proton_config.compatdata:gsub("'", "'\\''").."' &> /dev/null")
			end)
		else
			gameCompatdata_ActionRow:set_sensitive(false)
			gameCompatdata_ActionRow.subtitle = "Not found. Try launching the game at least once ?"
		end
	else
		gameCompatdata_ActionRow.visible = false
	end

	--[[
		LINKS
	]]
	local protonDBPage_Button = interface:get_object("protonDBPage_Button")
	lgiHelper.replaceSignal(protonDBPage_Button, "on_clicked", function()
		os.execute("xdg-open 'https://www.protondb.com/app/"..steamGameData.id.."' &> /dev/null")
	end)

	local steamDBPage_Button = interface:get_object("steamDBPage_Button")
	lgiHelper.replaceSignal(steamDBPage_Button, "on_clicked", function()
		os.execute("xdg-open 'https://steamdb.info/app/"..steamGameData.id.."' &> /dev/null")
	end)

	local PCGamingWikiPage_Button = interface:get_object("PCGamingWikiPage_Button")
	lgiHelper.replaceSignal(PCGamingWikiPage_Button, "on_clicked", function()
		os.execute("xdg-open 'https://www.pcgamingwiki.com/wiki/"..steamGameData.name:gsub(" ", "_").."' &> /dev/null")
	end)

	local SteambasePage_Button = interface:get_object("SteambasePage_Button")
	lgiHelper.replaceSignal(SteambasePage_Button, "on_clicked", function()
		os.execute("xdg-open 'https://steambase.io/apps/"..steamGameData.id.."' &> /dev/null")
	end)
end
