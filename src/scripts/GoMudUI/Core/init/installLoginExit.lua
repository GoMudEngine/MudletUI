ui = ui or {}

function ui.connected()
    ui = ui or {}
end

function ui.justLoggedIn()
    tempTimer(10, [[ ui.checkForUpdate() ]])
end

function ui.profileLoaded()
    -------------[ Load any saved tables into the name space ]-------------

    -- Prevent double initialization
    if ui.containersCreated then
        ui.displayUIMessage("UI already initialized, skipping duplicate initialization")
        return
    end

    -- Debug: Check GMCP status at start of profileLoaded
    ui.debugGMCP("profileLoaded START")

    -- Check GMCP status but don't preserve
    if gmcp and next(gmcp) then
        ui.displayUIMessage("<yellow>DEBUG: GMCP data found at profileLoaded start<reset>")
    else
        ui.displayUIMessage("<red>DEBUG: No GMCP data found at profileLoaded start<reset>")
    end

    -- Load saved settings if any
    if io.exists(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.settings.lua") then
        table.load(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.settings.lua", ui.settings) -- using / is OK on Windows too.
        ui.displayUIMessage("Settings Table Loaded")
    else
        -- If we don't find any saved settings load the standard settings
        ui.createSettings()
    end

    -- Load the known rooms table
    if io.exists(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.knownRooms.lua") then
        table.load(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.knownRooms.lua", ui.knownRooms) -- using / is OK on Windows too.
        ui.displayUIMessage("Known rooms loaded")
    end

    -- Load the rooms notes
    if io.exists(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.roomNotes.lua") then
        table.load(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.roomNotes.lua", ui.roomNotes) -- using / is OK on Windows too.
        ui.displayUIMessage("Room notes loaded")
    end
    -- Check if we have a crowd map version downloaded

    -- Crowmap has been disabled currently.

    --if io.exists(getMudletHomeDir().."/map downloads/current") then
    --  ui.crowdmapVersionFile = io.open(getMudletHomeDir().."/map downloads/current",r) -- using / is OK on Windows too.
    --  ui.crowdmapVersion = ui.crowdmapVersionFile:read("*number")
    --end

    ui.displayUIMessage("Initializing UI")

    -- Debug: Check GMCP status before creating containers
    ui.debugGMCP("profileLoaded BEFORE CONTAINERS")

    ui.createContainers("startup")

    -- Initialize developer tools
    if ui.dev and ui.dev.init then
        ui.dev.init()
    end

    if ui.postInstallDone then
        expandAlias("ui", false)
        ui.postInstallDone = false
    end

    -- Containers will be created, which we can check later
    ui.displayUIMessage("Profile loaded complete")
end

function ui.saveOnExit()
    ui.displayUIMessage("Saving UI tables")
    table.save(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.settings.lua", ui.settings)
    table.save(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.knownRooms.lua", ui.knownRooms)
    table.save(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.roomNotes.lua", ui.roomNotes)
end

function ui.postInstallHandling(_, package)
    -- Debug: Check GMCP at start of postInstallHandling
    ui.debugGMCP("postInstallHandling START for package: " .. package)

    if package == "mudlet-mapper" then
        mmp = mmp or {}
        raiseEvent("mmp logged in", "gomud")
        mmp.game = "gomud"
        mmp.echo("We're connected to GoMud.")
        -- Debug: Check GMCP after mudlet-mapper handling
        ui.debugGMCP("postInstallHandling AFTER mudlet-mapper")
    end

    if package == "GoMudUI" then
        --Check if the generic_mapper package is installed and if so uninstall it
        -- DISABLED: This causes issues with package reloading
        -- The generic_mapper can coexist with GoMudMapper
        --[[
		if table.contains(getPackages(), "generic_mapper") then
			ui.displayUIMessage("Note: generic_mapper detected but will not be removed")
		end
		--]]

        -- Options for pre-relase versions:
        if string.find(ui.version, "pre") then
            ui.displayUIMessage("This is a pre-release version. Version is: " .. ui.version)
            ui.profileLoaded()
            ui.connected()
        end
        --ui.createContainers("startup")

        -- Check if there is a map loaded already
        if table.is_empty(getRooms()) then
            -- there is no map loaded, but if you want a secondary doublecheck
            if table.size(getAreaTable()) == 1 then
                -- only has the defaultarea, and no rooms, so there's definitely no map loaded
                --ui.displayUIMessage("No map loaded")
                --ui.displayUIMessage("Use 'mconfig crowdmap on' to use the crowd map")
                -- just download a file and save it in our profile folder
            end
        end

        -- Install IRE mapping script
        if not table.contains(getPackages(), "GoMudMapper") then
            ui.displayUIMessage("Now installing custom GoMud mapper script")
            -- Debug: Check GMCP before GoMudMapper installation
            ui.debugGMCP("BEFORE GoMudMapper installation")
            tempTimer(1, function()
                installPackage(
                    "https://github.com/GoMudEngine/MudletMapper/releases/latest/download/GoMudMapper.mpackage"
                )

                -- Debug: Check GMCP after installation with delay
                tempTimer(2, function()
                    ui.debugGMCP("AFTER GoMudMapper installation")
                end)
            end)
        end

        ui.postInstallDone = true

        if not ui.isUpdating then
            -- Only call profileLoaded if containers haven't been created yet
            if not ui.containersCreated then
                ui.profileLoaded()
            else
                ui.displayUIMessage("Skipping profileLoaded - UI already initialized")
            end
        else
            -- Debug: Check GMCP during update
            ui.debugGMCP("During update - checking GMCP")
            ui.isUpdating = false
            -- Update all displays with current data
            ui.updateDisplays()
        end
        ui.updateTopBar()
    end
end

function ui.gameEngineCommand()
    if not gmcp.Client.GUI.gomudui then
        return
    end
    local command = gmcp.Client.GUI.gomudui
    if command == "update" then
        ui.manualUpdate = true
        ui.checkForUpdate()
    end
    if command == "remove" then
        ui.displayUIMessage("Now removing UI package from Mudlet")
        uninstallPackage("GoMudUI")
    end
end

function ui.unInstall(event, package)
    if package == "GoMudUI" then
        -- Check if this is an update (from autoupdater or muddler CI)
        if ui.isUpdating then
            ui.displayUIMessage("Package update detected - preserving profile state")
            -- Only hide UI elements, don't reset profile
            if ui.left then ui.left:hide() end
            if ui.right then ui.right:hide() end
            if ui.bottom then ui.bottom:hide() end
            if ui.top then ui.top:hide() end

            setBorderBottom(0)
            setBorderTop(0)
            setBorderLeft(0)
            setBorderRight(0)
            return
        end

        -- This is a user-initiated uninstall
        ui.displayUIMessage("Cleaning up - removing the UI mapper")
        uninstallPackage("GoMudMapper")

        ui.displayUIMessage("Re-installing the generic mapper")
        if not table.contains(getPackages(), "generic_mapper") then
            tempTimer(1, function()
                installPackage(
                    "https://raw.githubusercontent.com/Mudlet/Mudlet/development/src/mudlet-lua/lua/generic-mapper/generic_mapper.xml"
                )
            end)
        end

        ui.displayUIMessage("Removing windows and resetting borders")
        if ui.left then ui.left:hide() end
        if ui.right then ui.right:hide() end
        if ui.bottom then ui.bottom:hide() end
        if ui.top then ui.top:hide() end

        setBorderBottom(0)
        setBorderTop(0)
        setBorderLeft(0)
        setBorderRight(0)
        setFont("main", "Bitstream Vera Sans Mono")

        -- Only reset profile for complete uninstall by user
        ui.displayUIMessage("Complete uninstall - will reset profile in 3 seconds")
        tempTimer(3, function()
            -- Double-check this is still a user uninstall, not an update
            if not ui.isUpdating then
                echo("\n\nSending profile reset\n\n")
                resetProfile()
            else
                ui.displayUIMessage("Profile reset cancelled - package update detected")
            end
        end)
    end
end
