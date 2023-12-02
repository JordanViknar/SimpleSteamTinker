-- External Modules
local lgi = require("lgi")
local Adw = lgi.Adw
local Gtk = lgi.Gtk

-- Internal Modules
local programMetadata = require("modules.extra.programMetadata")

-- Translation fake function
local function _(text) return text end

return function(application, interface, win)
	local creditLauncher = interface:get_object("aboutLauncher")
	creditLauncher.on_clicked = function()
		-- Create window with main metadata already set
		local creditWindow = Adw.AboutWindow{
			application = application,
			modal = true,

			application_icon = programMetadata.icon_name,
			application_name = programMetadata.name,
			version = programMetadata.version,

			title = _("About ")..programMetadata.name,
			developer_name = programMetadata.developer,
			website = programMetadata.url,
			issue_url = programMetadata.url.."/issues",
			license_type = Gtk.License.MPL_2_0,

			developers = {
				"JordanViknar https://github.com/JordanViknar",
			},
			artists = {
				"JordanViknar https://github.com/JordanViknar"
			},
			documenters = {
				"JordanViknar https://github.com/JordanViknar"
			}
		}

		-- Credits
		creditWindow:add_acknowledgement_section(_("Inspired by"),{
			"SteamTinkerLaunch https://github.com/sonic2kk/steamtinkerlaunch",
			"Bottles https://github.com/bottlesdevs/Bottles"
		})
		creditWindow:add_acknowledgement_section(_("Powered by"),{
			"Lua https://www.lua.org/",
			"LGI https://github.com/lgi-devs/lgi",
			"GTK https://www.gtk.org/",
			"LibAdwaita https://gnome.pages.gitlab.gnome.org/libadwaita/",
			"LuaFileSystem https://github.com/lunarmodules/luafilesystem",
			"LuaSocket https://github.com/lunarmodules/luasocket",
			"dkjson http://dkolf.de/src/dkjson-lua.fsl/home"
		})
		creditWindow:add_acknowledgement_section(_("Third-Party Tools, Libraries and Special Thanks"),{
			"Steam https://store.steampowered.com/",
			"Proton https://github.com/ValveSoftware/proton",
			"GameMode https://github.com/FeralInteractive/gamemode",
			"MangoHud https://github.com/flightlessmango/MangoHud",
			"Zink https://docs.mesa3d.org/drivers/zink.html",
			"ProtonDB https://www.protondb.com/"
		})

		creditWindow:set_comments(_("A work-in-progress fast, simple and modern Libadwaita alternative to SteamTinkerLaunch."))

		creditWindow:set_transient_for(win)
		creditWindow:present()
	end
end
