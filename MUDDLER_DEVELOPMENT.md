# Muddler Development Guide for GoMudUI

## Overview

When developing GoMudUI with muddler, the package needs special handling to prevent GMCP data from being cleared during development rebuilds.

## The Problem

During normal package uninstallation, GoMudUI calls `resetProfile()` to clean up the Mudlet profile. However, during muddler CI builds, the package is constantly being uninstalled and reinstalled, which would clear GMCP data and cause issues.

## The Solution

GoMudUI now uses Mudlet's event system to detect package updates and preserve GMCP data. The package includes an event handler that listens for `sysUninstallPackage` events and sets the appropriate flags.

## Setup for Muddler CI

Add event handlers to your CI helper script (outside the package) BEFORE creating the Muddler helpers:

```lua
-- Register event handler to catch uninstalls
if not GoMudUI_CI_Handler then
    GoMudUI_CI_Handler = registerAnonymousEventHandler("sysUninstallPackage", function(event, package)
        if package == "GoMudUI" then
            ui = ui or {}
            ui.isUpdating = true
            cecho("\n<yellow>CI Helper: Detected GoMudUI uninstall - preserving GMCP<reset>\n")
        end
    end)
end

-- Your existing CI helpers
myCIhelper = myCIhelper or Muddler:new({
    path = "/Users/jens/mud/MudletUI"
})
```

That's it! Your GMCP data will now be preserved during muddler builds.

## How It Works

1. The `sysUninstallPackage` event fires BEFORE the package is removed
2. Your CI helper's event handler sets `ui.isUpdating = true` immediately
3. The package's `ui.unInstall` function checks this flag
4. If true, it only hides UI elements without calling `resetProfile()`
5. The 3-second timer also checks the flag before resetting the profile
6. GMCP data is preserved!

## Manual Control (if needed)

If you prefer manual control, you can set the flag directly:

Before running muddler:
```lua
ui.isUpdating = true
```

After muddler completes:
```lua
ui.isUpdating = false
```

## Understanding the Behavior

- **With `ui.isUpdating = true`**: The package uninstall will only hide UI elements without resetting the profile
- **With `ui.isUpdating = false`**: Full uninstall occurs, including `resetProfile()` after 3 seconds
- **Default behavior**: If the flag is not set, full uninstall occurs (safe for end users)

## Testing Your Setup

1. Check GMCP data before build:
   ```lua
   display(gmcp)
   ```

2. Run your muddler build

3. Check GMCP data after build:
   ```lua
   display(gmcp)
   ```

If GMCP data is preserved, your setup is working correctly.

## Troubleshooting

If GMCP is still being cleared:

1. Verify `ui.isUpdating` is set to `true` before the build
2. Check that your muddler version supports hooks
3. Ensure the package name in the uninstall handler matches exactly: "GoMudUI"
4. Use the GMCP monitor to track when data is cleared:
   ```lua
   ui.gmcpMonitor.start()
   ```

## Notes for Package Maintainers

- The `ui.isUpdating` flag is also used by the auto-updater
- Always test both development updates and end-user uninstalls
- The 3-second delay before `resetProfile()` gives time for the UI to clean up gracefully