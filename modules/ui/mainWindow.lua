-- Internal Modules
local programMetadata = require("modules.extra.programMetadata")
local configManager = require("modules.config.configManager")

-- External Modules
local lgi = require("lgi")
local Gtk = lgi.require("Gtk")
local Adw = lgi.Adw

return function(app, steamGames)
	-- We create the window
	local builder = Gtk.Builder.new_from_file(programMetadata.installdir.."ui/main.ui")
	local win = builder:get_object("mainWindow")
	win.application = app
	win.title = programMetadata.name
	win.startup_id = programMetadata.name

	-- Icon
	win:set_icon_name(programMetadata.icon_name)

	-- Check for dev version and add relevant theme
	if programMetadata.version:find("dev") then
		win:add_css_class("devel")
	end

	--[[
		UI ELEMENTS
	]]
	-- Page management
	local mainView = builder:get_object("mainView")
	local gameList = builder:get_object("gameList")
	local gameSettingsInterface = builder:get_object("gameSettings")
	-- Topbar
	local topbar = builder:get_object("topbar")
	-- Buttons
	local backToMenu = builder:get_object("backToMenu")

	-- Stack test
	local stack = builder:get_object("gameSettingsStack")

	-- For every game that has SimpleSteamMod enabled, we add a button in this list
	for _, game in pairs(steamGames) do
		if game.type == "game" then
			local statusIcon, statusLabel, statusColor
			-- Status label and icon
			if game.status == true then
				statusIcon = "emblem-default-symbolic"
				statusLabel = programMetadata.name.." is enabled for this game."
				statusColor = "success"
			elseif game.status == "SteamTinkerLaunch" then
				statusIcon = "emblem-important-symbolic"
				statusLabel = "SteamTinkerLaunch is enabled for this game instead of "..programMetadata.name.."."
				statusColor = "warning"
			else
				statusIcon = "dialog-error-symbolic"
				statusLabel = programMetadata.name.." is disabled for this game."
				statusColor = ""
			end

			-- OS Label
			local osLabel, osColor, osTooltip
			if game.os_platform == "Linux" then
				osLabel = "Native"
				osColor = "success"
				osTooltip = "This is a native Linux game."
			elseif game.os_platform == "Windows" then
				osLabel = "Proton"
				osColor = "accent"
				osTooltip = "This is a Windows game running through Proton."
			end

			-- The row
			local row = Adw.ActionRow {
				title = game.name,
				subtitle = game.location,
				use_markup = false, -- Used to escape the ampersand
				activatable = true,
				subtitle_lines = 1
			}

			-- The game's image
			local image = Gtk.Image {
				file = game.images.icon,
				icon_size = Gtk.IconSize.LARGE
			}
			row:add_prefix(image)

			local box = Gtk.Box {
				orientation = Gtk.Orientation.HORIZONTAL,
				spacing = 12,
				Gtk.Label {
					label = osLabel,
					css_classes = { osColor, "dim-label" },
					has_tooltip = true,
					tooltip_text = osTooltip
				},
				Gtk.Image {
					icon_name = statusIcon,
					valign = Gtk.Align.CENTER,
					halign = Gtk.Align.CENTER,
					has_tooltip = true,
					tooltip_text = statusLabel,
					css_classes = { statusColor }
				}
			}
			local button = Gtk.Button {
				id = "button",
				icon_name = "go-next-symbolic",
				has_frame = false,
				valign = Gtk.Align.CENTER,
				halign = Gtk.Align.CENTER,
				css_classes = { "circular", "flat", "image-button" },
				on_clicked = function()
					-- We setup the gameSettings UI for this game
					require("modules.ui.gameSettingsOverview")(app, builder, game)
					local gameSettings = configManager.getGameConfig(game.id)
					require("modules.ui.gameSettingsSettings")(app, builder, game, gameSettings)
					require("modules.ui.gameSettingsUtilities")(app, builder, game, gameSettings)
					require("modules.ui.gameSettingsProton")(app, builder, game, gameSettings)
					require("modules.ui.gameSettingsGamescope")(app, builder, game, gameSettings)

					collectgarbage("collect")
					mainView:push(gameSettingsInterface)
				end
			}
			box:append(button)
			row:add_suffix(box)
			row.activatable_widget = button

			gameList:add(row)
		end
	end

	--Topbar management
	topbar:set_top_bar_style(Adw.ToolbarStyle.RAISED_BORDER)
	gameSettingsInterface.on_showing = function()
		topbar:set_top_bar_style(Adw.ToolbarStyle.RAISED)
	end
	gameSettingsInterface.on_shown = function ()
		backToMenu:set_visible(true)
	end
	gameSettingsInterface.on_hiding = function()
		topbar:set_top_bar_style(Adw.ToolbarStyle.RAISED_BORDER)
		backToMenu:set_visible(false)
	end
	-- Overview restoration when we exit out of the settings
	gameSettingsInterface.on_hidden = function()
		stack:set_visible_child_name("overviewPage")
	end

	-- Button to go back to the main menu
	backToMenu.on_clicked = function()
		mainView:pop()
	end

	-- Credits
	require("modules.ui.aboutWindow")(app, builder, win)
end
