function ui.updatePetDisplay()
    -- Only update if we have the required display
    if not ui.charDisplay then
        return
    end

    -- Only try to display pets if GMCP data exists
    if not gmcp or not gmcp.Char or not gmcp.Char.Pets then
        -- Don't clear or write anything if no data
        return
    end

    -- Clear and update the pets tab
    ui.charDisplay:clear("Pets")
    ui.charDisplay:cecho("Pets", "<cyan>Your companions\n\n")

    local pets_list = gmcp.Char.Pets
    if type(pets_list) ~= "table" or #pets_list == 0 then
        ui.charDisplay:cecho("Pets", "\n  <sandy_brown>You have no pets.")
    else
        -- Calculate column widths
        local totalWidth = math.floor(ui.charDisplay:get_width() / ui.consoleFontWidth)
        local nameWidth = totalWidth - 20 -- Leave 20 chars for Type and Hunger columns
        local typeWidth = 10
        local hungerWidth = 10

        -- Display headers
        local headerFormat = "<white>%-" .. nameWidth .. "s%-" .. typeWidth .. "s%" .. hungerWidth .. "s\n"
        ui.charDisplay:cecho("Pets", string.format(headerFormat, "Name", "Type", "Hunger"))
        ui.charDisplay:cecho("Pets",
            "<grey>" .. string.rep("-", math.floor(ui.charDisplay:get_width() / ui.consoleFontWidth)) .. "\n")

        -- Display each pet
        for i, pet in ipairs(pets_list) do
            if type(pet) == "table" then
                local petName = tostring(pet.name or "Unknown")
                local petType = tostring(pet.type or "unknown")
                local petHunger = tostring(pet.hunger or "unknown")

                -- Truncate name if too long
                if #petName > nameWidth - 1 then
                    petName = string.sub(petName, 1, nameWidth - 4) .. "..."
                end

                -- Color code hunger status based on stages
                local hungerColor = "<grey>"
                if petHunger == "full" then
                    hungerColor = "<green>"
                elseif petHunger == "well fed" then
                    hungerColor = "<light_green>"
                elseif petHunger == "hungry" then
                    hungerColor = "<yellow>"
                elseif petHunger == "starving" then
                    hungerColor = "<orange>"
                elseif petHunger == "dying" then
                    hungerColor = "<red>"
                end

                -- Create the formatted line
                local lineFormat = "<sandy_brown>%-" ..
                nameWidth .. "s<reset>%-" .. typeWidth .. "s" .. hungerColor .. "%" .. hungerWidth .. "s\n"
                ui.charDisplay:cecho("Pets", string.format(lineFormat, petName, petType, petHunger))
            end
        end
    end
end

-- Function to manually show pets when the tab is clicked
function ui.showPetsTab()
    ui.updatePetDisplay()
end
