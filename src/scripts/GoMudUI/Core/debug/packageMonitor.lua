-- Package Installation Monitor
-- This script monitors package installations and uninstallations to track GMCP state

ui = ui or {}
ui.debug = ui.debug or {}

-- Create wrapper functions to monitor package operations
if not ui.debug.originalInstallPackage then
    ui.debug.originalInstallPackage = installPackage
    ui.debug.originalUninstallPackage = uninstallPackage
    
    -- Override installPackage
    function installPackage(packagePath)
        ui.displayUIMessage("<cyan>DEBUG: installPackage called for: " .. tostring(packagePath) .. "<reset>")
        ui.debugGMCP("BEFORE installPackage: " .. tostring(packagePath))
        
        -- Call original function
        local result = ui.debug.originalInstallPackage(packagePath)
        
        -- Check GMCP after a delay
        tempTimer(1, function()
            ui.debugGMCP("AFTER installPackage: " .. tostring(packagePath))
        end)
        
        return result
    end
    
    -- Override uninstallPackage
    function uninstallPackage(packageName)
        ui.displayUIMessage("<cyan>DEBUG: uninstallPackage called for: " .. tostring(packageName) .. "<reset>")
        ui.debugGMCP("BEFORE uninstallPackage: " .. tostring(packageName))
        
        -- Call original function
        local result = ui.debug.originalUninstallPackage(packageName)
        
        -- Check GMCP after a delay
        tempTimer(1, function()
            ui.debugGMCP("AFTER uninstallPackage: " .. tostring(packageName))
        end)
        
        return result
    end
end

-- Monitor sysInstallPackage and sysUninstall events
function ui.debug.onPackageInstalled(event, packageName)
    ui.displayUIMessage("<cyan>DEBUG: sysInstallPackage event for: " .. tostring(packageName) .. "<reset>")
    ui.debugGMCP("sysInstallPackage event: " .. tostring(packageName))
end

function ui.debug.onPackageUninstalled(event, packageName)
    ui.displayUIMessage("<cyan>DEBUG: sysUninstall event for: " .. tostring(packageName) .. "<reset>")
    ui.debugGMCP("sysUninstall event: " .. tostring(packageName))
end

-- Register event handlers
registerNamedEventHandler("ui", "debug-package-install", "sysInstallPackage", "ui.debug.onPackageInstalled")
registerNamedEventHandler("ui", "debug-package-uninstall", "sysUninstall", "ui.debug.onPackageUninstalled")

ui.displayUIMessage("<yellow>Package monitoring initialized<reset>")