ui = ui or {}

-- Simple state tracking
ui.isUpdating = false

-- Centralized data persistence functions
function ui.saveUserData()
    local dataDir = getMudletHomeDir() .. "/GoMudUI"

    -- Ensure directory exists
    if not io.exists(dataDir) then
        lfs.mkdir(dataDir)
    end

    -- Save container sizes if containers exist
    if ui.left and ui.right and ui.top and ui.bottom then
        ui.containerSizes = {
            left = ui.left:get_width(),
            right = ui.right:get_width(),
            top = ui.top:get_height(),
            bottom = ui.bottom:get_height()
        }
    end

    -- Save only what matters
    table.save(dataDir .. "/ui.settings.lua", ui.settings)
    table.save(dataDir .. "/ui.knownRooms.lua", ui.knownRooms)
    table.save(dataDir .. "/ui.roomNotes.lua", ui.roomNotes)
    table.save(dataDir .. "/ui.containerSizes.lua", ui.containerSizes)

    ui.displayUIMessage("UI data saved")
end

function ui.loadUserData()
    local dataDir = getMudletHomeDir() .. "/GoMudUI"

    -- Load settings
    if io.exists(dataDir .. "/ui.settings.lua") then
        table.load(dataDir .. "/ui.settings.lua", ui.settings)
        ui.displayUIMessage("Settings loaded")
    else
        ui.createSettings()
    end

    -- Load known rooms
    if io.exists(dataDir .. "/ui.knownRooms.lua") then
        table.load(dataDir .. "/ui.knownRooms.lua", ui.knownRooms)
        ui.displayUIMessage("Known rooms loaded")
    end

    -- Load room notes
    if io.exists(dataDir .. "/ui.roomNotes.lua") then
        table.load(dataDir .. "/ui.roomNotes.lua", ui.roomNotes)
        ui.displayUIMessage("Room notes loaded")
    end

    -- Load container sizes
    ui.containerSizes = {}
    if io.exists(dataDir .. "/ui.containerSizes.lua") then
        table.load(dataDir .. "/ui.containerSizes.lua", ui.containerSizes)
        ui.displayUIMessage("Container sizes loaded")
    end
end

-- Connection event handler
function ui.connected()
    -- Request game info immediately on connection
    sendGMCP("GMCP SendGameInfo")
end

-- Just logged in handler
function ui.justLoggedIn()
    tempTimer(10, [[ ui.checkForUpdate() ]])
end

-- Profile loaded handler
function ui.profileLoaded()
    -- Load all user data
    ui.loadUserData()

    -- Only create containers if they don't exist or aren't visible
    if not ui.left or not ui.left.visible then
        ui.displayUIMessage("Initializing UI")
        ui.createContainers("startup")
    end

    -- Request fresh GMCP data
    sendGMCP("GMCP SendFullPayload")
end

-- Package install handler
function ui.handlePackageInstall(_, package)
    if package == "mudlet-mapper" then
        mmp = mmp or {}
        raiseEvent("mmp logged in", "gomud")
        mmp.game = "gomud"
        mmp.echo("We're connected to " .. ui.getGameName() .. ".")
        return
    end

    if package ~= "GoMudUI" then return end

    -- Always ensure settings exist
    if not ui.settings or not ui.settings.consoleFont then
        ui.loadUserData()
    end

    -- Always create containers on install
    ui.createContainers("startup")

    -- Handle mapper installation
    if table.contains(getPackages(), "generic_mapper") then
        ui.displayUIMessage("Removing standard mapping script")
        if map and map.registeredEvents then
            for _, id in ipairs(map.registeredEvents) do
                killAnonymousEventHandler(id)
            end
        end
        tempTimer(1, function() uninstallPackage("generic_mapper") end)
    end

    -- Install custom mapper if needed
    if not table.contains(getPackages(), "GoMudMapper") then
        ui.displayUIMessage("Installing custom mapper script")
        tempTimer(1, function()
            installPackage("https://github.com/GoMudEngine/MudletMapper/releases/download/v2.0.3/GoMudMapper.mpackage")
        end)
    end

    -- Check version type
    if string.find(ui.version, "pre") then
        ui.displayUIMessage("Pre-release version: " .. ui.version)
    end

    -- Handle update vs fresh install
    if ui.isUpdating then
        ui.isUpdating = false
        ui.displayUIMessage("Update complete!")
    else
        ui.displayUIMessage("UI installed!")
    end

    -- Always request GMCP data
    sendGMCP("GMCP SendFullPayload")

    -- Update top bar
    ui.updateTopBar()
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

-- Package uninstall handler
function ui.handlePackageUninstall(_, package)
    if package ~= "GoMudUI" then return end

    -- Save user data before uninstall
    ui.saveUserData()

    -- Only do visual cleanup if not updating
    if not ui.isUpdating then
        ui.displayUIMessage("Cleaning up UI")

        -- Hide containers
        if ui.left then ui.left:hide() end
        if ui.right then ui.right:hide() end
        if ui.top then ui.top:hide() end
        if ui.bottom then ui.bottom:hide() end

        -- Reset borders
        setBorderBottom(0)
        setBorderTop(0)
        setBorderLeft(0)
        setBorderRight(0)

        -- Uninstall mapper
        ui.displayUIMessage("Removing custom mapper")
        uninstallPackage("GoMudMapper")

        -- Reinstall generic mapper
        ui.displayUIMessage("Re-installing generic mapper")
        if not table.contains(getPackages(), "generic_mapper") then
            tempTimer(1, function()
                installPackage(
                    "https://raw.githubusercontent.com/Mudlet/Mudlet/development/src/mudlet-lua/lua/generic-mapper/generic_mapper.xml")
            end)
        end

        -- Reset font
        setFont("main", "Bitstream Vera Sans Mono")

        -- Reset profile after a delay
        tempTimer(3, function() resetProfile() end)
    end
end
