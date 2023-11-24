# This script should be used after modifying any of the ui_definitions files.
# It will compile the ui_definitions files into ui files that GTK can use.
# If you do not, the modifications you've made to the UI outside of Lua code will not be applied.

blueprint-compiler compile $(dirname $0)/ui_definitions/mainWindow.blp > $(dirname $0)/ui/main.ui
