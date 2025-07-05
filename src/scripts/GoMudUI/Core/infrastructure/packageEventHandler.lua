-- Package Event Handler
-- Handles post-install cleanup for package updates
-- Note: For muddler CI, use external event handlers in your CI helper script

ui = ui or {}
ui.packageEvents = ui.packageEvents or {}

-- Handler for post-install event
function ui.packageEvents.afterInstall(event, package)
    if package ~= "GoMudUI" then
        return
    end
    
    -- If we just reinstalled after an update, clear the flag
    if ui.isUpdating then
        ui.displayUIMessage("Package update complete - clearing update flag")
        -- Clear the flag after a short delay to ensure all initialization is done
        tempTimer(0.5, function()
            ui.isUpdating = false
        end)
    end
end

-- Only register the post-install handler
-- Pre-uninstall must be handled externally for muddler CI
registerAnonymousEventHandler("sysInstallPackage", ui.packageEvents.afterInstall)

ui.displayUIMessage("Package event handler initialized")