> [!IMPORTANT]
> SimpleSteamTinker is still in ***HEAVY*** development and very unfinished.
> Expect an incomplete interface and lots of missing/unstable features.
>
> If SteamTinkerLaunch is fast enough for you and fits your needs, you should not use this tool right now.
>
> With that being said, I'd still very much appreciate people testing SimpleSteamTinker and reporting [issues](https://github.com/JordanViknar/SimpleSteamTinker/issues) or contributing.

<div align="center">
	<img src="./assets/icons/scalable/simplesteamtinker.svg" width=172>
	<h1>SimpleSteamTinker</h1>
	<p align="center">A work-in-progress simple, fast, and modern Adwaita alternative to SteamTinkerLaunch.</p>
	<!-- Badges -->
	<img src="https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white">
	</br>
	<img src="https://img.shields.io/github/license/JordanViknar/SimpleSteamTinker?color=orange">
	<img src="https://img.shields.io/github/commit-activity/m/JordanViknar/SimpleSteamTinker?color=orange">
	<img src="https://img.shields.io/github/repo-size/JordanViknar/SimpleSteamTinker">
	</br>
	<!-- Screenshot -->
	<img src="./assets/screenshots/ViewLight.png" width=768>
</div>

## Description

### Situation

I like [SteamTinkerLaunch](https://github.com/sonic2kk/steamtinkerlaunch), I like it a lot. In fact, I consider it to be one of the most important tools for Linux gaming.

However, it has always been flawed to me : it is *slow*, it is not comfortable to use, and the user interface is very messy.

I want Linux Gaming to be for **everyone**. SteamTinkerLaunch, as a tool, ***fails*** to make itself easily usable by non-technical users.

Finally, one time, my curiosity led me to look inside its source code, only to be met with a single Bash script containing 26 000 lines. At that point, I decided there should be an alternative to it.

*And thus came SimpleSteamTinker...*

### Goal

*TL;DR : Simple, Fast, Modern & User-Friendly*

SimpleSteamTinker aims right now to be only an alternative to SteamTinkerLaunch, not to replace it : I do not intend to implement the more complex features of it that the average user won't need.

Using Lua, a fast and simple language, and Adwaita, a modern user-friendly interface system, the goal of this project is to have a clean and easy but *powerful* way of launching Steam games with custom options and tools.

It takes inspiration from [Bottles](https://github.com/bottlesdevs/Bottles) and Adwaita applications in general.

Additionally, I consider SimpleSteamTinker should work *with* Steam rather than hack/replace its features. Anything that can be easily done on the Steam side of things will not be implemented (Proton version management for example. If you want to use Proton-GE, I'd recommend [ProtonPlus](https://github.com/Vysp3r/ProtonPlus) or [ProtonUp-Qt](https://github.com/DavidoTek/ProtonUp-Qt)).

And finally, as a side goal : prove that Lua can *also* be used for developing modern applications, just like for example Python (which I often see in Adwaita apps).

## Installation

### Arch Linux-based distributions

SimpleSteamTinker can be installed from Arch Linux, Manjaro, and variants through the provided [PKGBUILD](./install/archlinux/PKGBUILD).

**Always** download the latest version of the PKGBUILD, then use **makepkg** in its directory.

It will eventually be made available on the AUR once the program is complete enough.

To enable a game in SimpleSteamTinker with this installation method, use this text as launch options in Steam :
```bash
sst %command%
```

### Packaging for other distributions

Here are informations which might be useful to you :

SimpleSteamTinker is meant to be installed in `/usr/share/SimpleSteamTinker` (except `sst` which goes into `/usr/bin`).
The system desktop file goes in `/usr/share/applications` and the icons go in `/usr/share/icons` like many applications.

Most of the file structure installation steps can be achieved with the Makefile.
It is recommended to use it if possible in your packaging system.

It depends on :
- Lua 5.4
- [LGI](https://github.com/lgi-devs/lgi) (development version **specifically**) + [GTK4](https://www.gtk.org/) + [libadwaita](https://gnome.pages.gitlab.gnome.org/libadwaita/)
- Steam installation, with a user configured and games installed.
- [LuaFileSystem](https://github.com/lunarmodules/luafilesystem)
- [LuaSocket](https://github.com/lunarmodules/luasocket) + [LuaSec](https://github.com/lunarmodules/luasec)
- [dkjson](https://dkolf.de/src/dkjson-lua.fsl/home)
- [xclip](https://github.com/astrand/xclip) *(Might be replaced/made optional in the future.)*
- [libnotify](https://gitlab.gnome.org/GNOME/libnotify)

And optionally (if they're missing, their related features will simply be disabled) :

[GameMode](https://github.com/FeralInteractive/gamemode), [MangoHud](https://github.com/flightlessmango/MangoHud), [Mesa](https://www.mesa3d.org/) *(for Zink support)*, [switcheroo-control](https://gitlab.freedesktop.org/hadess/switcheroo-control) and [Gamescope](https://github.com/ValveSoftware/gamescope).

## Development

Simply install the project's dependencies described earlier and clone it.

To test the launch of Steam games, insert in their launch options :
```bash
/PATH/TO/CLONED/REPO/sst %command%
```
For example, in my case `/PATH/TO/CLONED/REPO/sst` is `/home/jordan/Programmation/SimpleSteamTinker/sst`.

Additionally, if you want to perform UI-related changes, you'll need [Blueprint](https://gitlab.gnome.org/jwestman/blueprint-compiler).
If, in the future, LGI becomes stable enough with GTK4 to use it directly to generate the UI, Blueprint might be dropped.

*Note : A desktop file won't be provided with this method, and icons won't be installed.*

## Comparison

### Development

| Development | SteamTinkerLaunch | SimpleSteamTinker |
| --- | --- | --- |
| Language | Bash | Lua |
| Code | 26k lines in a single file | Neatly organised in modules and commented |
| UI definitions | Mashed into the code | (Mostly) done in separate GTK Blueprint files |
| Interface system | yad + GTK3 | LGI + GTK4 + libadwaita |
| License | GPL-3.0 | MPL-2.0 |

### Interface

| Features (interface) | SteamTinkerLaunch | SimpleSteamTinker |
| --- | --- | --- |
| Launch speed (on primary laptop) | ❌ (25 seconds) | ✅ (1 second) |
| Game list | ❌ | ✅ |
| Game status | ❌ | ✅ |
| ProtonDB integration | ✅ | ✅ |
| Launch Button | ✅ | ✅ |
| Steam AppID | ✅ | ✅ |
| Notifications | ✅ | ✅ |
| Pre-game launch window | ✅ | ❌ *(Not implemented to speed up game startup and not get in the user's way. Might change in the future.)* |
| Categories | ✅ | ❌ |
| Custom default game config | ✅ | ❌ |
| Game location | ~ *(separate button)* | ✅ |
| Compatdata location | ❌ | ✅ |
| Help pages *(ProtonDB, PCGamingWiki, SteamDB)* | ~ *(messy to access)* | ✅ |

### Tools, settings, etc.

*(Note : Native Linux features/tools/settings are prioritized over alternatives designed for Windows.)*

| Features (tools, settings, etc.) | SteamTinkerLaunch | SimpleSteamTinker |
| --- | --- | --- |
| Non-Steam game support | ✅ | ❌ *([Bottles](https://github.com/bottlesdevs/Bottles) recommended)* |
| Proton version management | ✅ | ❌ *([ProtonPlus](https://github.com/Vysp3r/ProtonPlus) recommended)* |
| dGPU management | ✅ | ✅ |
| GameMode | ✅ | ✅ |
| Custom launch system | ✅ | 🚧 *(Planned, high priority)* |
| Winetricks | ✅ | ❌ *(Planned ?)* |
| Protontricks | ❌ | ❌ *(Planned ?)* |
| Proton settings | ✅ | 🚧 *(Planned, high priority)* |
| DXVK settings | ✅ | 🚧 *(Planned, high priority)* |
| VKD3D settings | ✅ | 🚧 *(Planned, high priority)* |
| FSR settings | ✅ | 🚧 *(Planned, high priority)* |
| MangoHud | ✅ | ✅ |
| Gamescope | ✅ | ✅ |
| Shader support (ReShade/vkBasalt) | ✅ | ❌ *(Planned, low priority)* |
| SDL Wayland video driver | ✅ | ✅ |
| Zink | ✅ | ✅ |
| PulseAudio latency | ✅ | 🚧 *(Planned)* |
| Vortex | ✅ | ❌ |
| Mod Organizer 2 | ✅ | ❌ |
| HedgeModManager | ✅ | ❌ *(Planned ?)* |
| geo-11 3D Driver | ✅ | ❌ |
| SpecialK | ✅ | ❌ |
| FlawlessWidescreen | ✅ | ❌ |
| Stereo3D | ✅ | ❌ |
| RADV Perftest Options | ✅ | ❌ *(Planned, low priority, cannot test properly due to lack of an AMD GPU)* |
| Steam Linux Runtime toggle | ✅ | ❌ |
| steamwebhelper toggle | ✅ | ❌ |
| obs-gamecapture | ✅ | ❌ |
| Nyrna | ✅ | ❌ |
| ReplaySorcery | ✅ | ❌ |
| Boxtron | ✅ | ❌ |
| Roberta | ✅ | ❌ |
| Luxtorpeda | ✅ | ❌ |
| Network monitoring and control | ✅ | ❌ |
| Discord Rich Presence | ✅ | ❌ *(Planned, low priority)* |

## Bug Reports / Contributions / Suggestions
You can report bugs or suggest features by making an issue, or you can contribute to this program directly by forking it and then sending a pull request.

Any help will be very much appreciated. Thank you.