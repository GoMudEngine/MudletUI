-- GMCP Protector
-- This script attempts to protect GMCP data during package operations

ui = ui or {}
ui.debug = ui.debug or {}

-- Store a backup of GMCP periodically
ui.debug.gmcpBackup = ui.debug.gmcpBackup or {}

function ui.debug.backupGMCP(context)
    if gmcp and next(gmcp) then
        ui.debug.gmcpBackup = table.deepcopy(gmcp)
        ui.debug.gmcpBackupTime = os.time()
        ui.debug.gmcpBackupContext = context or "periodic"
        --ui.displayUIMessage("<dim_grey>DEBUG: GMCP backed up (" .. ui.debug.gmcpBackupContext .. ")<reset>")
    end
end

function ui.debug.restoreGMCPIfNeeded()
    if (not gmcp or not next(gmcp)) and ui.debug.gmcpBackup and next(ui.debug.gmcpBackup) then
        local timeSinceBackup = os.time() - (ui.debug.gmcpBackupTime or 0)
        ui.displayUIMessage(string.format(
            "<red>GMCP was cleared! Restoring from backup (age: %d seconds, context: %s)<reset>",
            timeSinceBackup,
            ui.debug.gmcpBackupContext or "unknown"
        ))
        gmcp = table.deepcopy(ui.debug.gmcpBackup)
        ui.debugGMCP("After restoration from backup")
        return true
    end
    return false
end

-- Backup GMCP before any package operation
function ui.debug.beforePackageOp(event, package)
    ui.debug.backupGMCP("before-" .. event .. "-" .. (package or "unknown"))
end

-- Check and restore GMCP after package operations
function ui.debug.afterPackageOp(event, package)
    tempTimer(0.5, function()
        if ui.debug.restoreGMCPIfNeeded() then
            ui.displayUIMessage("<yellow>GMCP restored after " .. event .. " of " .. (package or "unknown") .. "<reset>")
            -- Update displays with restored data
            if ui.updateDisplays then
                ui.updateDisplays()
            end
        end
    end)
end

-- Register handlers for package events
registerNamedEventHandler("ui", "gmcp-protect-preinstall", "sysInstallPackage", "ui.debug.beforePackageOp")
registerNamedEventHandler("ui", "gmcp-protect-postinstall", "sysInstallPackage", "ui.debug.afterPackageOp")
registerNamedEventHandler("ui", "gmcp-protect-preuninstall", "sysUninstall", "ui.debug.beforePackageOp")
registerNamedEventHandler("ui", "gmcp-protect-postuninstall", "sysUninstall", "ui.debug.afterPackageOp")

-- Periodic backup (every 30 seconds)
if ui.debug.gmcpBackupTimer then
    killTimer(ui.debug.gmcpBackupTimer)
end
ui.debug.gmcpBackupTimer = tempTimer(30, function()
    ui.debug.backupGMCP("periodic")
    ui.debug.gmcpBackupTimer = tempTimer(30, function() ui.debug.backupGMCP("periodic") end)
end)

-- Initial backup
ui.debug.backupGMCP("initial")

ui.displayUIMessage("<yellow>GMCP protection initialized<reset>")