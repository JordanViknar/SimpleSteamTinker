-- Internal Modules
local toolObject = require("modules.objects.toolObject")

local name = "/usr/lib/dri/zink_dri.so"
local toolType = "environmentVariable"
local usage = function(command, config)
	if config.dgpu.enabled and require("modules.tools.switcherooctl").isInstalled then
		-- We override switcherooctl (in its function) and let Zink handle the dGPU
		return "DRI_PRIME=1 __GLX_VENDOR_LIBRARY_NAME=mesa MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink"
	else
		return "MESA_LOADER_DRIVER_OVERRIDE=zink"
	end
end

return toolObject:new(name, toolType, usage)
