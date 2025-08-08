function ui.createContainers(arg)
    -- Ensure settings exist before proceeding
    if not ui.settings or not ui.settings.consoleFont then
        ui.displayUIMessage("Warning: Settings not loaded, loading now...")
        ui.loadUserData()
    end
    
    -- Do some caltulations on font sizes to make sure everything fits into the console we create
    -- By calculating the pixel width of the font, we are able to make sure we size the consoles and windows correctly
    ui.consoleFontWidth, ui.consoleFontHeight = calcFontSize(ui.settings.consoleFontSize, ui.settings.consoleFont)

    -- If someone sets a different font/fontsize in the main window, lets make sure we have that defined as well
    ui.mainFontWidth, ui.mainFontHeight = calcFontSize(getFontSize("main"), getFont(main))

    -- Lets calculate the gauge font sizes as well
    ui.gaugeFontWidth, ui.gaugeFontHeight = calcFontSize(ui.settings.gaugeFontSize, ui.settings.consoleFont)

    -- Lets calculate the prompt font sizes as well
    ui.promptFontWidth, ui.promptFontHeight = calcFontSize(ui.settings.promptFontSize, ui.settings.consoleFont)

    -------------[ If a full reset is required ]-------------
    local arg = arg
    local containerAutoload = true

    if arg == "reset" then
        for k, v in pairs(ui.settings.containers) do
            if ui[k] then
                ui[k]:deleteSaveFile()
                ui[k] = nil
            end
            ui.top = nil
            ui.left = nil
            ui.right = nil
            ui.bottom = nil
            containerAutoload = false
        end
        for k, v in pairs(ui.settings.displays) do
            ui[k] = nil
            containerAutoload = false
        end
    end

    -------------[ Calculate container sizes ]-------------
    local totalWidth = select(1, getMainWindowSize())
    local leftWidth, rightWidth, topHeight, bottomHeight

    -- Check if we have saved sizes and this isn't a reset
    if ui.containerSizes and ui.containerSizes.left and arg ~= "reset" then
        -- Use saved sizes
        leftWidth = ui.containerSizes.left
        rightWidth = ui.containerSizes.right
        topHeight = ui.containerSizes.top
        bottomHeight = ui.containerSizes.bottom
    else
        -- Use default calculations
        leftWidth = ui.consoleFontWidth * 40 + 4 -- 44 chars + margin
        topHeight = "4c"                         -- Default from below
        bottomHeight = 105                       -- Default from below

        -- Calculate right container width: 30% default, but ensure main has 100 chars
        local mainMinWidth = ui.mainFontWidth * 100    -- 100 chars minimum for main
        local rightMinWidth = ui.consoleFontWidth * 45 -- 45 chars minimum for right

        -- Start with 30% for right side
        rightWidth = math.floor(totalWidth * 0.3)

        -- Check if this leaves enough space for main console
        local mainWidth = totalWidth - leftWidth - rightWidth
        if mainWidth < mainMinWidth then
            -- Reduce right panel to ensure main gets 100 chars
            rightWidth = totalWidth - leftWidth - mainMinWidth

            -- But ensure right panel has at least 45 chars
            if rightWidth < rightMinWidth then
                rightWidth = rightMinWidth
            end
        end
    end

    -------------[ Start by building the borders ]-------------

    ui.top = ui.top or Adjustable.Container:new({
        name = "ui.top",
        y = 0,
        height = topHeight,
        padding = 4,
        attachedMargin = 0,
        adjLabelstyle = ui.settings.topCSS,
        autoLoad = false -- Don't autoload when using explicit sizes
    })

    ui.bottom = ui.bottom or Adjustable.Container:new({
        name = "ui.bottom",
        height = bottomHeight,
        y = (type(bottomHeight) == "number") and (-bottomHeight) or ("-" .. bottomHeight),
        padding = 4,
        attachedMargin = 0,
        adjLabelstyle = ui.settings.bottomCSS,
        autoLoad = false -- Don't autoload when using explicit sizes
    })

    ui.right = ui.right or Adjustable.Container:new({
        name = "ui.right",
        y = "0%",
        x = "-" .. rightWidth .. "px",
        height = "100%",
        width = rightWidth .. "px",
        padding = 2,
        attachedMargin = 0,
        adjLabelstyle = ui.settings.rightCSS,
        autoLoad = false -- Don't autoload, we're setting size explicitly
    })

    ui.left = ui.left or Adjustable.Container:new({
        name = "ui.left",
        x = "0%",
        y = "0%",
        height = "100%",
        width = (leftWidth - 4) .. "px", -- Subtract attachedMargin
        padding = 2,
        attachedMargin = 4,
        adjLabelstyle = ui.settings.leftCSS,
        autoLoad = false -- Don't autoload, we're setting size explicitly
    })


    ui.top:attachToBorder("top")
    ui.bottom:attachToBorder("bottom")
    ui.left:attachToBorder("left")
    ui.right:attachToBorder("right")

    ui.top:connectToBorder("left")
    ui.top:connectToBorder("right")
    ui.bottom:connectToBorder("left")
    ui.bottom:connectToBorder("right")


    ui.top:lockContainer("border")
    ui.left:lockContainer("border")
    ui.right:lockContainer("border")
    ui.bottom:lockContainer("border")

    -- Knowing the window size, lets us calculate how mush space we can use for everything else and still display the mud output
    ui.mainWindowWidth = select(1, getMainWindowSize()) - ui.left:get_width() - ui.right:get_width()

    -------------[ Build the adjustable containers ]-------------
    for k, v in pairs(ui.settings.containers) do
        local consoleHeight = ""
        local consoleY = ""
        local w, h
        if v.fs then
            w, h = calcFontSize(v.fs, ui.settings.consoleFont)
        else
            h = ui.consoleFontHeight
        end

        if assert(type(v.height)) == "number" then
            consoleHeight = h * v.height
        else
            consoleHeight = v.height
        end
        if assert(type(v.y)) == "number" then
            consoleY = h * v.y
        else
            consoleY = v.y
        end

        local containerName = "ui." .. k

        ui[k] = ui[k] or Adjustable.Container:new({
            name = containerName,
            titleText = k,
            x = v.x or 0,
            y = consoleY,
            padding = 5,
            attachedMargin = 0,
            width = v.width or "100%",
            autoWrap = v.wrap or false,
            height = consoleHeight,
            fontSize = v.fs or ui.settings.consoleFontSize,
            adjLabelstyle = v.customCSS or ui.settings.moveableConsoleCSS,
            autoLoad = containerAutoload
        }, ui[v.dest])

        ui[k]:newCustomItem("Move to left side",
            function(self)
                ui.putContainer("left", k)
            end
        )

        ui[k]:newCustomItem("Move to right side",
            function(self)
                ui.putContainer("right", k)
            end
        )

        ui[k]:newCustomItem("Move to bottom",
            function(self)
                ui.putContainer("bottom", k)
            end
        )

        ui[k]:newCustomItem("Move to top",
            function(self)
                ui.putContainer("top", k)
            end
        )

        ui[k]:newCustomItem("Pop out",
            function(self)
                ui.popOutContainer(k)
            end
        )

        ui[k]:lockContainer("border")
    end

    -------------[ Build the EMCO and Miniconsole objects ]-------------

    for k, v in pairs(ui.settings.displays) do
        local containerName = "ui." .. k
        local console = v.tabs

        if v.emco and not v.mapper then
            ui[k] = EMCO:new({
                name = containerName,
                x = 0,
                y = 2,
                width = "100%",
                height = "100%",
                tabFontSize = ui.settings.tabFontSize,
                tabHeight = ui.settings.tabHeight,
                gap = ui.settings.tabGap,
                fontSize = ui.settings.consoleFontSize,
                font = ui.settings.consoleFont,
                tabFont = ui.settings.consoleFont,
                autoWrap = v.wrap or false,
                tabBoxColor = ui.settings.tabBarColor,
                consoleColor = ui.settings.consoleBackgroundColor,
                activeTabFGColor = ui.settings.activeTabFGColor,
                activeTabCSS = ui.settings.activeTab,
                inactiveTabFGColor = ui.settings.inactiveTabFGColor,
                inactiveTabCSS = ui.settings.inactiveTab,
                consoles = console
            }, ui[v.dest])
            ui[k]:disableAllLogging()
        elseif v.mapper then
            ui[k] = EMCO:new({
                name = containerName,
                x = 0,
                y = 2,
                width = "100%",
                height = "100%",
                tabFontSize = ui.settings.tabFontSize,
                tabHeight = ui.settings.tabHeight,
                gap = ui.settings.tabGap,
                fontSize = ui.settings.consoleFontSize,
                font = ui.settings.consoleFont,
                tabFont = ui.settings.consoleFont,
                allTab = false,
                autoWrap = false,
                mapTab = true,
                mapTabName = v.mapTab,
                tabBoxColor = ui.settings.consoleBackgroundColor,
                consoleContainerColor = ui.settings.consoleBackgroundColor,
                consoleColor = ui.settings.consoleBackgroundColor,
                activeTabFGColor = ui.settings.activeTabFGColor,
                activeTabCSS = ui.settings.activeTab,
                inactiveTabFGColor = ui.settings.inactiveTabFGColor,
                inactiveTabCSS = ui.settings.inactiveTab,
                consoles = console
            }, ui[v.dest])
            ui[k]:disableAllLogging()

            -- Set a map zoom level that is comfortable for most people
            setMapZoom(10)

            -- Set the mapper background color the same as everything else
            setMapBackgroundColor(15, 15, 15)
        else
            ui[k] = Geyser.MiniConsole:new({
                name = containerName,
                x = v.x or 0,
                y = 0,
                width = v.width or "100%",
                padding = 4,
                height = "100%",
                fontSize = ui.settings.promptFontSize,
                font = ui.settings.consoleFont,
                adjLabelstyle = ui.settings.noborderConsoleCSS,
                autoWrap = false,
                color = ui.settings.consoleBackgroundColor,
                autoLoad = containerAutoload,
            }, ui[v.dest])
        end
    end

    ui.createPlayerGuages()
    if arg == "layout_update" then
        ui.updateDisplays({ type = "update" })
    else
        ui.updateDisplays()
    end

    if arg == "reset" then
        ui.displayUIMessage("UI layout set to default")
        raiseWindow("mapper")
        sendGMCP("GMCP SendFullPayload")
    end
    if arg == "startup" then
        -- Only do final adjustment if we don't have saved sizes
        if not (ui.containerSizes and ui.containerSizes.left) then
            local totalWidth = select(1, getMainWindowSize())
            local currentMainWidth = totalWidth - ui.left:get_width() - ui.right:get_width()
            local targetMainWidth = ui.mainFontWidth * 100 -- 100 characters

            if currentMainWidth < targetMainWidth then
                -- Right panel is too wide, resize it
                local newRightWidth = totalWidth - ui.left:get_width() - targetMainWidth
                if newRightWidth > ui.consoleFontWidth * 45 then -- Ensure at least 45 chars for right
                    ui.right:resize(newRightWidth, "100%")
                end
            end
        end

        ui.displayUIMessage("UI containers created\n")
        raiseEvent("UICreated")
        raiseWindow("mapper")
        sendGMCP("GMCP SendFullPayload")
    end
end
