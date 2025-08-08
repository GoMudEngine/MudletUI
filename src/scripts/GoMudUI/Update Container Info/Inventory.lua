function ui.updateInvDisplay()
    if gmcp.Char == nil then return end
    if gmcp.Char.Inventory == nil then return end
    if gmcp.Char.Inventory.Backpack == nil then return end
    if gmcp.Char.Inventory.Backpack.Items == nil then return end

    ui.eqDisplay:clear("Inventory")

    ui.eqDisplay:cecho("Inventory", "<cyan>R/C to look, drop or wear\n\n")
    
    local backpackItems = gmcp.Char.Inventory.Backpack.Items

    if #backpackItems > 0 then
        -- Calculate column widths
        local totalWidth = math.floor(ui.eqDisplay:get_width() / ui.consoleFontWidth)
        local itemWidth = totalWidth - 11  -- Leave 11 chars for Stack and Uses columns
        local stackWidth = 6
        local usesWidth = 5
        
        -- Display headers
        local headerFormat = "<white>%-" .. itemWidth .. "s%-" .. stackWidth .. "s%" .. usesWidth .. "s\n"
        ui.eqDisplay:cecho("Inventory", string.format(headerFormat, "Item", "Stack", "Uses"))
        ui.eqDisplay:cecho("Inventory", "<grey>" .. string.rep("-", math.floor(ui.eqDisplay:get_width() / ui.consoleFontWidth)) .. "\n")
        
        -- Group items by name for stacking
        local itemStacks = {}
        for _, item in ipairs(backpackItems) do
            local itemName = item.name or "unknown"
            if not itemStacks[itemName] then
                itemStacks[itemName] = {
                    items = {},
                    totalUses = 0
                }
            end
            table.insert(itemStacks[itemName].items, item)
            itemStacks[itemName].totalUses = itemStacks[itemName].totalUses + (tonumber(item.uses) or 0)
        end
        
        -- Display items
        for itemName, stack in pairs(itemStacks) do
            local firstItem = stack.items[1]
            local stackCount = #stack.items
            local uses = firstItem.uses or 0
            
            -- Format the item name
            local displayName = ui.titleCase(itemName)
            if #displayName > itemWidth - 1 then
                displayName = string.sub(displayName, 1, itemWidth - 4) .. "..."
            end
            
            -- Format stack count
            local stackText = ""
            if stackCount > 1 then
                stackText = tostring(stackCount)
            else
                stackText = "-"
            end
            
            -- Format uses
            local usesText = ""
            if tonumber(uses) > 0 then
                if stackCount > 1 then
                    -- Show total uses for stacked items
                    usesText = tostring(stack.totalUses)
                else
                    usesText = tostring(uses)
                end
            else
                usesText = "-"
            end
            
            -- Create the formatted line
            local lineFormat = "<sandy_brown>%-" .. itemWidth .. "s<reset>%-" .. stackWidth .. "s%" .. usesWidth .. "s\n"
            local lineText = string.format(lineFormat, displayName, stackText, usesText)
            
            -- Build popup commands and hints
            local popupCommands = {
                [[send("look ]] .. firstItem.id .. [[", false)]],
                [[send("drop ]] .. firstItem.id .. [[", false)]],
            }
            local popupHints = {
                "Look at " .. ui.titleCase(itemName),
                "Drop " .. ui.titleCase(itemName),
            }
            
            -- Add custom command if available (exclude picklock since it needs a target)
            if firstItem.command and firstItem.command ~= "" and firstItem.command ~= "picklock" then
                table.insert(popupCommands, [[send("]] .. firstItem.command .. [[ ]] .. firstItem.id .. [[", false)]])
                table.insert(popupHints, ui.titleCase(firstItem.command) .. " " .. ui.titleCase(itemName))
            end
            
            ui.eqDisplay:cechoPopup("Inventory",
                lineText,
                popupCommands,
                popupHints,
                true
            )
        end
    else
        ui.eqDisplay:cecho("Inventory", "\n  <sandy_brown>You are not carrying anything.")
    end
end
