-- Internal Modules
local programMetadata = require("modules.extra.programMetadata")
local configManager = require("modules.config.configManager")
local systemUtils = require("modules.general.systemUtils")
local lgiHelper = require("modules.ui.lgiHelper")

-- External Modules
local lgi = require("lgi")
local Gtk = lgi.require("Gtk")
local Adw = lgi.Adw

-- Install checks
local installedList = {}

return function(app, steamGames)
	-- We create the window
	local builder = Gtk.Builder.new_from_file(programMetadata.installdir.."ui/main.ui")
	local win = builder:get_object("mainWindow")
	win.application = app
	win.title = programMetadata.name
	win.startup_id = programMetadata.name

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
					-- We setup the gameSettings Overview UI for this game
					require("modules.ui.gameSettingsOverview")(app, builder, game)

					-- We connect the UI elements to the game settings
					local gameSettings = configManager.getGameConfig(game.id)
					local UIelements = require("modules.ui.UItoSettingsList")
					
					-- We iterate through the UI elements
					for widgetname, data in pairs(UIelements) do
						local widget = builder:get_object(widgetname)

						-- Split the setting into keys
						local keys = {}
						for substring in data.setting:gmatch("[^.]+") do
							keys[#keys + 1] = substring
						end
						-- Connect to the settings table
						local pointer = gameSettings
						for i = 1, #keys - 1 do
							pointer = pointer[keys[i]] or {}
						end

						-- We determine the right signal to use
						local signal
						if data.type == "Switch" then
							signal = "on_state_set"
						elseif data.type == "SpinRow" then
							signal = "on_changed"
						elseif data.type == "Toggle" then
							signal = "on_toggled"
						else
							error("Unknown signal to use with type '"..data.type.."' for UI element '"..widgetname.."'")
						end

						-- Should they be active ? Is the related tool installed ?
						if not installedList[data.tool] then
							installedList[data.tool] = systemUtils.isInstalled(data.tool)
						end
						if installedList[data.tool] == false then
							widget:set_sensitive(false)
							widget.has_tooltip = true
							widget.tooltip_text = "'"..data.tool.."' is not present on your system."
						else
							lgiHelper.removeSignal(widget, signal)
							widget:set_sensitive(true)

							if data.type == "Switch" or data.type == "Toggle" then
								widget:set_active(pointer[keys[#keys]])
								lgiHelper.replaceSignal(widget, signal,function() configManager.modifyGameConfig(game.id, data.setting, widget:get_active()) end)
							elseif data.type == "SpinRow" then
								widget.value = pointer[keys[#keys]]
								lgiHelper.replaceSignal(widget, signal,function() configManager.modifyGameConfig(game.id, data.setting, math.floor(widget:get_value())) end)
							else
								error("Unknown type '"..data.type.."' for UI element '"..widgetname.."'")
							end
						end
					end

					--[[
						Special cases that I'll have to optimize later
					]]
					-- Proton page
					local protonPage = builder:get_object("protonPage")
					if game.os_platform == "Windows" then
						protonPage.visible = true
					else
						protonPage.visible = false
					end
					-- For that one comboRow
					local comboRow = builder:get_object("gamescope_Filtering_Filter_ComboRow")
					local model = comboRow:get_model()

					lgiHelper.removeSignal(comboRow, "notify")

					local filters = {"Linear","Nearest","FSR","NIS","Pixel"}
					-- Iterate through the filters array
					for index, filter in ipairs(filters) do
						if gameSettings.gamescope.filtering.filter == filter then
							comboRow:set_selected(index - 1)
							break -- No need to continue
						end
					end

					lgiHelper.replaceSignal(comboRow, "on_notify", function()
						local setting = model:get_string(comboRow:get_selected())
						configManager.modifyGameConfig(game.id, "gamescope.filtering.filter", setting)
					end)

					-- We finally push the settings page to the user.
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
	builder:get_object("mainPageTopbar"):set_top_bar_style(Adw.ToolbarStyle.RAISED_BORDER)
	builder:get_object("gameSettingsTopbar"):set_top_bar_style(Adw.ToolbarStyle.RAISED_BORDER)

	-- Overview restoration when we exit out of the settings
	gameSettingsInterface.on_hidden = function()
		stack:set_visible_child_name("overviewPage")
	end

	-- Credits
	require("modules.ui.aboutWindow")(app, builder, win)
end
