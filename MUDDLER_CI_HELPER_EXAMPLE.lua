-- CI Helper Script for GoMudUI
-- This script should be placed in your Mudlet profile, NOT in the package
-- It ensures GMCP data is preserved during muddler builds

-- IMPORTANT: This event handler must be registered BEFORE running muddler
-- It catches the uninstall event and sets the flag to preserve GMCP
if not GoMudUI_CI_Handler then
    GoMudUI_CI_Handler = registerAnonymousEventHandler("sysUninstallPackage", function(event, package)
        if package == "GoMudUI" then
            -- Set the flag immediately when uninstall starts
            ui = ui or {}
            ui.isUpdating = true
            cecho("\n<yellow>CI Helper: Detected GoMudUI uninstall - preserving GMCP<reset>\n")
        end
    end)
end

-- Also register a handler to clear the flag after install
if not GoMudUI_CI_Install_Handler then
    GoMudUI_CI_Install_Handler = registerAnonymousEventHandler("sysInstallPackage", function(event, package)
        if package == "GoMudUI" and ui and ui.isUpdating then
            cecho("\n<green>CI Helper: GoMudUI reinstalled - clearing update flag<reset>\n")
            tempTimer(1, function()
                ui.isUpdating = false
            end)
        end
    end)
end

-- Your existing CI helpers
myCIhelper = myCIhelper or Muddler:new({
    path = "/Users/jens/mud/MudletUI"
})

myCIhelper2 = myCIhelper2 or Muddler:new({
    path = "/Users/jens/mud/MudletMapper"
})