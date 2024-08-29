
local filesystem = require("Filesystem")
local GUI = require("GUI")
local paths = require("Paths")
local system = require("System")

local workspace, icon, menu = select(1, ...), select(2, ...), select(3, ...)
local localization = system.getSystemLocalization()

local function CallFileExplorer(path)
	local component = require("Component")
	local screen = require("Screen")
	path = filesystem.removeSlashes(path)

	local oldScreenWidth, oldScreenHeight, success, errorPath, line, traceback = screen.getResolution()

	if filesystem.exists(path) then
		success, reason = loadfile(path)

		if success then
			success, errorPath, line, traceback = system.call(success)
		else
			success, errorPath, line, traceback = false, path, tonumber(reason:match(":(%d+)%:")) or 1, reason
		end
	else
		GUI.alert("File \"" .. tostring(path) .. "\" doesn't exists")
	end

	component.proxy(screen.getGPUProxy().getScreen()).setPrecise(false)
	screen.setResolution(oldScreenWidth, oldScreenHeight)

	if not success then
		system.error(errorPath, line, traceback)
	end

	return success, errorPath, line, traceback
end

menu:addItem(localization.launch).onTouch = function()
	system.execute(icon.path)
end

menu:addItem(localization.launchWithArguments).onTouch = function()
	system.launchWithArguments(icon.path)
end

menu:addItem(localization.flashEEPROM, not component.isAvailable("eeprom") or filesystem.size(icon.path) > 4096).onTouch = function()
	local container = GUI.addBackgroundContainer(workspace, true, true, localization.flashEEPROM)
	container.layout:addChild(GUI.label(1, 1, container.width, 1, 0x969696, localization.flashingEEPROM)):setAlignment(GUI.ALIGNMENT_HORIZONTAL_CENTER, GUI.ALIGNMENT_VERTICAL_TOP)
	workspace:draw()

	component.get("eeprom").set(filesystem.read(icon.path))
	
	container:remove()
	workspace:draw()
end

system.addUploadToPastebinMenuItem(menu, icon.path)

menu:addItem("launch without S mode check").onTouch = function()
	CallFileExplorer(icon.path)
end
