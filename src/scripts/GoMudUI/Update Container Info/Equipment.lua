function ui.updateEQDisplay()
    if not gmcp.Char or not gmcp.Char.Inventory then return end

    ui.eqDisplay:clear("Equipment")
    ui.eqDisplay:cecho("Equipment", "<cyan>R/C to look or remove\n\n")

    -- Get all locations from Worn inventory
    local locations = {}
    if gmcp.Char.Inventory.Worn then
        for location, _ in pairs(gmcp.Char.Inventory.Worn) do
            table.insert(locations, location)
        end
    end

    -- Sort locations alphabetically
    table.sort(locations)

    if #locations > 0 then
        -- Calculate column widths
        local totalWidth = math.floor(ui.eqDisplay:get_width() / ui.consoleFontWidth)
        local locationWidth = 8
        local itemWidth = totalWidth - locationWidth - 6 -- Leave 6 chars for Uses column
        local usesWidth = 6

        -- Display headers
        local headerFormat = "<white>%-" .. locationWidth .. "s%-" .. itemWidth .. "s%" .. usesWidth .. "s\n"
        ui.eqDisplay:cecho("Equipment", string.format(headerFormat, "Location", "Item", "Uses"))
        ui.eqDisplay:cecho("Equipment",
            "<grey>" .. string.rep("-", math.floor(ui.eqDisplay:get_width() / ui.consoleFontWidth)) .. "\n")

        -- Display each equipment slot
        for _, slot in ipairs(locations) do
            local item = nil
            -- Check Worn for the item
            if gmcp.Char.Inventory.Worn and gmcp.Char.Inventory.Worn[slot] and gmcp.Char.Inventory.Worn[slot].name ~= "" and gmcp.Char.Inventory.Worn[slot].name ~= "-nothing-" then
                item = gmcp.Char.Inventory.Worn[slot]
            end

            -- Format slot name
            local slotName = ui.titleCase(slot)
            if #slotName > locationWidth - 1 then
                slotName = string.sub(slotName, 1, locationWidth - 4) .. "..."
            end

            if not item then
                -- Empty slot
                local lineFormat = "<snow>%-" ..
                locationWidth .. "s<red>%-" .. itemWidth .. "s<reset>%" .. usesWidth .. "s\n"
                ui.eqDisplay:cecho("Equipment", string.format(lineFormat, slotName, "---", "-"))
            else
                -- Format item name
                local itemName = ui.titleCase(item.name)
                if #itemName > itemWidth - 1 then
                    itemName = string.sub(itemName, 1, itemWidth - 4) .. "..."
                end

                -- Format uses
                local usesText = "-"
                if item.uses and tonumber(item.uses) > 0 then
                    usesText = tostring(item.uses)
                end

                -- Create the formatted line
                local lineFormat = "<snow>%-" ..
                locationWidth .. "s<sandy_brown>%-" .. itemWidth .. "s<reset>%" .. usesWidth .. "s\n"
                local lineText = string.format(lineFormat, slotName, itemName, usesText)

                -- Build popup commands and hints
                local popupCommands = {
                    [[send("look ]] .. item.id .. [[", false)]],
                    [[send("remove ]] .. item.id .. [[", false)]],
                }
                local popupHints = {
                    "Look at " .. ui.titleCase(item.name),
                    "Remove " .. ui.titleCase(item.name),
                }

                -- Add custom command if available (exclude picklock since it needs a target)
                if item.command and item.command ~= "" and item.command ~= "picklock" then
                    table.insert(popupCommands, [[send("]] .. item.command .. [[ ]] .. item.id .. [[", false)]])
                    table.insert(popupHints, ui.titleCase(item.command) .. " " .. ui.titleCase(item.name))
                end

                ui.eqDisplay:cechoPopup("Equipment",
                    lineText,
                    popupCommands,
                    popupHints,
                    true
                )
            end
        end
    else
        ui.eqDisplay:cecho("Equipment", "\n  <sandy_brown>No equipment slots available.")
    end
end
