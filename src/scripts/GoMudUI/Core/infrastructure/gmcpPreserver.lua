-- GMCP Preserver
-- This module ensures GMCP data is never lost during UI operations

ui = ui or {}
ui.gmcpPreserver = ui.gmcpPreserver or {}

-- Store a backup of GMCP data
ui.gmcpPreserver.backup = nil
ui.gmcpPreserver.lastBackupTime = 0
ui.gmcpPreserver.enabled = true

-- Create a backup of current GMCP data
function ui.gmcpPreserver.createBackup()
	if gmcp and type(gmcp) == "table" and next(gmcp) then
		ui.gmcpPreserver.backup = table.deepcopy(gmcp)
		ui.gmcpPreserver.lastBackupTime = os.time()
		return true
	end
	return false
end

-- Restore GMCP from backup
function ui.gmcpPreserver.restore()
	if ui.gmcpPreserver.backup and type(ui.gmcpPreserver.backup) == "table" then
		gmcp = table.deepcopy(ui.gmcpPreserver.backup)
		ui.displayUIMessage("<green>GMCP data restored from backup<reset>")
		-- Update all displays with restored data
		if ui.updateDisplays then
			ui.updateDisplays()
		end
		return true
	end
	return false
end

-- Check if GMCP needs restoration
function ui.gmcpPreserver.check()
	-- If GMCP is empty or nil but we have a backup, restore it
	if (not gmcp or not next(gmcp)) and ui.gmcpPreserver.backup then
		ui.displayUIMessage("<yellow>GMCP data was cleared! Restoring from backup...<reset>")
		ui.gmcpPreserver.restore()
	end
end

-- Initialize the preserver
function ui.gmcpPreserver.init()
	-- Create initial backup
	ui.gmcpPreserver.createBackup()
	
	-- Set up periodic backup (every 30 seconds)
	if ui.gmcpPreserver.backupTimer then
		killTimer(ui.gmcpPreserver.backupTimer)
	end
	ui.gmcpPreserver.backupTimer = tempTimer(30, function()
		ui.gmcpPreserver.createBackup()
		ui.gmcpPreserver.init() -- Reschedule
	end)
	
	-- Set up periodic check (every 2 seconds)
	if ui.gmcpPreserver.checkTimer then
		killTimer(ui.gmcpPreserver.checkTimer)
	end
	ui.gmcpPreserver.checkTimer = tempTimer(2, function()
		if ui.gmcpPreserver.enabled then
			ui.gmcpPreserver.check()
		end
		ui.gmcpPreserver.init() -- Reschedule
	end)
end

-- Hook into package installation to preserve GMCP
local originalInstallPackage = installPackage
function installPackage(...)
	-- Backup GMCP before installing
	ui.gmcpPreserver.createBackup()
	
	-- Call original function
	local result = originalInstallPackage(...)
	
	-- Check and restore GMCP after a short delay
	tempTimer(0.5, function()
		ui.gmcpPreserver.check()
	end)
	
	return result
end

-- Hook into package uninstallation to preserve GMCP
local originalUninstallPackage = uninstallPackage
function uninstallPackage(packageName)
	-- Backup GMCP before uninstalling
	ui.gmcpPreserver.createBackup()
	
	-- Don't interfere with our own uninstall
	if packageName == "GoMudUI" and ui.isUpdating then
		ui.gmcpPreserver.enabled = false
		tempTimer(5, function()
			ui.gmcpPreserver.enabled = true
		end)
	end
	
	-- Call original function
	local result = originalUninstallPackage(packageName)
	
	-- Check and restore GMCP after a short delay
	tempTimer(0.5, function()
		ui.gmcpPreserver.check()
	end)
	
	return result
end

-- Start the preserver
ui.gmcpPreserver.init()
ui.displayUIMessage("<green>GMCP Preserver initialized - your game data is now protected<reset>")