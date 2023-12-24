# Metadata
PROJECT_NAME=simplesteamtinker
INSTALL_FOLDER_NAME=SimpleSteamTinker
VERSION=indev

ifeq ($(PREFIX),)
    PREFIX := /usr
endif
BUILD_FOLDER := dist/

.PHONY: system install uninstall clean local

# -------------- System installation --------------
# This will create a folder structure in dist that is compatible with most package managers.
system:
	@echo "Packaging project for system installation..."
# Executable
	mkdir -p $(BUILD_FOLDER)$(PREFIX)/bin
	install -Dm755 sst $(BUILD_FOLDER)$(PREFIX)/bin
# Modules
	mkdir -p $(BUILD_FOLDER)$(PREFIX)/share/$(INSTALL_FOLDER_NAME)
	install -Dm644 main.lua $(BUILD_FOLDER)$(PREFIX)/share/$(INSTALL_FOLDER_NAME)/main.lua
	cp -r modules $(BUILD_FOLDER)$(PREFIX)/share/$(INSTALL_FOLDER_NAME)
# UI
	mkdir -p $(BUILD_FOLDER)$(PREFIX)/share/$(INSTALL_FOLDER_NAME)/ui
	install -Dm644 ui/main.ui $(BUILD_FOLDER)$(PREFIX)/share/$(INSTALL_FOLDER_NAME)/ui/main.ui
# Desktop file
	mkdir -p $(BUILD_FOLDER)$(PREFIX)/share/applications
	install -Dm644 assets/desktop/system.desktop $(BUILD_FOLDER)$(PREFIX)/share/applications/$(PROJECT_NAME).desktop
# Icons
	mkdir -p $(BUILD_FOLDER)$(PREFIX)/share/icons/hicolor/256x256/apps
	mkdir -p $(BUILD_FOLDER)$(PREFIX)/share/icons/hicolor/scalable/apps
	install -Dm644 assets/icons/256x256.png $(BUILD_FOLDER)$(PREFIX)/share/icons/hicolor/256x256/apps/$(PROJECT_NAME).png
	install -Dm644 assets/icons/scalable.svg $(BUILD_FOLDER)$(PREFIX)/share/icons/hicolor/scalable/apps/$(PROJECT_NAME).svg

# Should only be used as last resort, the end user should use a compatible package manager if possible instead.
# This is only here for testing purposes, and also as a general "manual" on how to install the project for package maintainers.
install: system
	@echo "Installing project to system..."
	cp -r $(BUILD_FOLDER)$(PREFIX)/bin/* $(PREFIX)/bin
	cp -r $(BUILD_FOLDER)$(PREFIX)/share/$(INSTALL_FOLDER_NAME) $(PREFIX)/share
	cp -r $(BUILD_FOLDER)$(PREFIX)/share/applications/* $(PREFIX)/share/applications
	cp -r $(BUILD_FOLDER)$(PREFIX)/share/icons/hicolor/256x256/apps/* $(PREFIX)/share/icons/hicolor/256x256/apps
	cp -r $(BUILD_FOLDER)$(PREFIX)/share/icons/hicolor/scalable/apps/* $(PREFIX)/share/icons/hicolor/scalable/apps
# Update icon cache
	@echo "Updating icon cache..."
	gtk-update-icon-cache $(PREFIX)/share/icons/hicolor
uninstall:
	@echo "Uninstalling project from system..."
	rm -ri $(PREFIX)/bin/sst
	rm -rI $(PREFIX)/share/$(INSTALL_FOLDER_NAME)
	rm -ri $(PREFIX)/share/applications/$(PROJECT_NAME).desktop
	rm -ri $(PREFIX)/share/icons/hicolor/256x256/apps/$(PROJECT_NAME).png
	rm -ri $(PREFIX)/share/icons/hicolor/scalable/apps/$(PROJECT_NAME).svg
# Update icon cache
	@ echo "Updating icon cache..."
	gtk-update-icon-cache $(PREFIX)/share/icons/hicolor

# -------------- Cleaning --------------

clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_FOLDER)
