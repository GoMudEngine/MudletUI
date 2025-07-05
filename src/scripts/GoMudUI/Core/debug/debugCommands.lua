-- Debug Commands for GoMudUI
-- Provides helpful commands for development and troubleshooting

ui = ui or {}
ui.debug = ui.debug or {}

-- Check update status
function ui.debug.checkUpdateStatus()
    ui.displayUIMessage(string.format("<yellow>Update Status:<reset> ui.isUpdating = %s", tostring(ui.isUpdating or false)))
    
    if ui.muddlerCI and ui.muddlerCI.isDevelopment then
        ui.displayUIMessage("<green>Muddler development environment detected<reset>")
    else
        ui.displayUIMessage("<gray>Standard environment<reset>")
    end
    
    if ui.muddlerCI and ui.muddlerCI.isUpdating then
        ui.displayUIMessage("<orange>Muddler CI update in progress<reset>")
    end
end

-- Toggle update mode (for testing)
function ui.debug.toggleUpdateMode()
    ui.isUpdating = not ui.isUpdating
    ui.displayUIMessage(string.format("<yellow>Update mode toggled:<reset> ui.isUpdating = %s", tostring(ui.isUpdating)))
    
    if ui.isUpdating then
        ui.displayUIMessage("<orange>WARNING: Profile reset is disabled while update mode is active<reset>")
    else
        ui.displayUIMessage("<green>Normal uninstall behavior restored<reset>")
    end
end

-- Test uninstall behavior without actually uninstalling
function ui.debug.testUninstall()
    ui.displayUIMessage("<yellow>Testing uninstall behavior...<reset>")
    
    if ui.isUpdating then
        ui.displayUIMessage("<green>RESULT: Would preserve profile (update mode active)<reset>")
    else
        ui.displayUIMessage("<red>RESULT: Would reset profile after 3 seconds (normal uninstall)<reset>")
    end
end

-- Show all debug info
function ui.debug.showInfo()
    ui.displayUIMessage(ui.createHeader("GoMudUI Debug Information", "", 80))
    ui.displayUIMessage(string.format("Version: %s", ui.version or "unknown"))
    ui.displayUIMessage(string.format("Package Name: %s", ui.packageName or "unknown"))
    ui.displayUIMessage(string.format("Update Mode: %s", tostring(ui.isUpdating or false)))
    ui.displayUIMessage(string.format("Containers Created: %s", tostring(ui.containersCreated or false)))
    ui.displayUIMessage(string.format("Post Install Done: %s", tostring(ui.postInstallDone or false)))
    
    -- Check GMCP status
    if gmcp then
        local count = 0
        for _ in pairs(gmcp) do
            count = count + 1
        end
        ui.displayUIMessage(string.format("GMCP Status: %d keys", count))
    else
        ui.displayUIMessage("GMCP Status: <red>nil<reset>")
    end
    
    -- Check muddler status
    if ui.muddlerCI then
        ui.displayUIMessage(string.format("Muddler Development: %s", tostring(ui.muddlerCI.isDevelopment or false)))
        ui.displayUIMessage(string.format("Muddler Updating: %s", tostring(ui.muddlerCI.isUpdating or false)))
    else
        ui.displayUIMessage("Muddler CI: Not loaded")
    end
end

-- Register commands
ui.debug.commands = {
    ["ui debug status"] = ui.debug.checkUpdateStatus,
    ["ui debug toggle"] = ui.debug.toggleUpdateMode,
    ["ui debug test"] = ui.debug.testUninstall,
    ["ui debug info"] = ui.debug.showInfo,
}

ui.displayUIMessage("<gray>Debug commands loaded - use 'ui debug info' for status<reset>")