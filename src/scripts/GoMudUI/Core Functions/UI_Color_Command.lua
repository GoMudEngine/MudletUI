-- UI Color command handler
function ui.colorCommand(args)
    if not args or args == "" then
        -- Show usage
        ui.displayUIMessage("Color command usage:")
        cecho("\n  <white>ui color activetab <yellow><colorname><grey> - Set active tab color")
        cecho("\n  <white>ui color inactivetab <yellow><colorname><grey> - Set inactive tab color")
        cecho("\n  <white>ui color show<grey> - Show all available colors")
        cecho("\n  <white>ui color activetab<grey> - Show colors to click for active tab")
        cecho("\n  <white>ui color inactivetab<grey> - Show colors to click for inactive tab\n")
        return
    end

    local words = string.split(args, " ")
    local command = words[1]
    local colorName = words[2]

    if command == "show" then
        -- Show all available colors
        ui.displayUIMessage("Available colors:\n")
        displayColors({
            cols = 4,
            echoOnly = true,
            removeDupes = true,
            justText = true
        })
        return
    elseif command == "activetab" then
        if colorName and color_table[colorName] then
            -- Set the active tab color
            ui.settings.activeTabBGColor = colorName
            ui.addCSSToSettings()
            ui.createContainers("layout_update")
            ui.displayUIMessage("Active tab color set to: " .. colorName)
        else
            -- Show clickable colors for active tab
            ui.displayUIMessage("Click a color to set as active tab color:")
            displayColors({
                cols = 4,
                uiSetting = "activeTabBGColor",
                removeDupes = true,
                justText = true
            })
        end
        return
    elseif command == "inactivetab" then
        if colorName and color_table[colorName] then
            -- Set the inactive tab color
            ui.settings.inactiveTabBGColor = colorName
            ui.addCSSToSettings()
            ui.createContainers("layout_update")
            ui.displayUIMessage("Inactive tab color set to: " .. colorName)
        else
            -- Show clickable colors for inactive tab
            ui.displayUIMessage("Click a color to set as inactive tab color:")
            displayColors({
                cols = 4,
                uiSetting = "inactiveTabBGColor",
                removeDupes = true,
                justText = true
            })
        end
        return
    else
        ui.displayUIMessage("Unknown color command: " .. command)
        ui.colorCommand() -- Show usage
    end
end
