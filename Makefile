# Metadata
PROJECT_NAME=stweaks
INSTALL_FOLDER_NAME=STWeaks
VERSION=indev

ifeq ($(PREFIX),)
    PREFIX := /usr
endif
BUILD_FOLDER := dist/

.PHONY: system install uninstall clean local

# -------------- Packaging --------------
$(BUILD_FOLDER)stweaks.luau:
	@echo "Using DarkLua to bundle Luau code..."
	darklua process init.luau $(BUILD_FOLDER)stweaks.luau -v

build: $(BUILD_FOLDER)stweaks.luau
	@echo "Compiling project..."
	lune build $(BUILD_FOLDER)stweaks.luau

run:
	@echo "Running project..."
	lune run init

# -------------- Cleaning --------------
clean:
	@echo "Cleaning up..."
	rm -rf "$(BUILD_FOLDER)"
