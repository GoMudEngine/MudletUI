function ui.updatePetDisplay()
    ui.updateDisplay("eqDisplay", "Pets", function(display, tabName)
        -- Always show header
        display:cecho(tabName, ui.createHeader("Pets", "Companions", display:get_width()) .. "\n")
        display:cecho(tabName, "<cyan>Right-click to interact\n")
        display:cecho(tabName, "<white>" .. string.format("%-15s%-15s%-10s", "Name", "Type", "Hunger") .. "\n")

        -- Check if pets data is available
        if not ui.hasGmcpData("Char", "Pets") then
            display:cecho(tabName, "\n<grey>No pets owned")
            display:cecho(tabName, "\n<grey>Waiting for pet data...")
            return
        end

        -- Get pets data - it's an array of pet objects
        local petsData = ui.getGmcpData({}, "Char", "Pets")

        if #petsData == 0 then
            display:cecho(tabName, "\n<grey>No pets owned")
        else
            -- Display each pet
            for _, pet in ipairs(petsData) do
                local petName = pet.name or "Unknown"
                local petType = pet.type or "Unknown"
                local petHunger = pet.hunger or "Unknown"

                -- Color code hunger status
                local hungerColor = "<yellow>"
                if petHunger == "full" then
                    hungerColor = "<green>"
                elseif petHunger == "hungry" then
                    hungerColor = "<orange>"
                elseif petHunger == "starving" then
                    hungerColor = "<red>"
                end

                display:cecho(tabName, "\n")

                -- Make the pet name clickable
                display:cechoPopup(tabName,
                    string.format("<sandy_brown>%-15s", petName),
                    {
                        string.format([[send("look %s", false)]], petName),
                        string.format([[send("pet %s", false)]], petName),
                        string.format([[send("feed %s", false)]], petName),
                        string.format([[send("dismiss %s", false)]], petName),
                    }, {
                        "Look at " .. petName,
                        "Pet " .. petName,
                        "Feed " .. petName,
                        "Dismiss " .. petName,
                    }, true
                )

                -- Display type and hunger (non-clickable)
                display:cecho(tabName, string.format("<reset>%-15s%s%s",
                    petType,
                    hungerColor,
                    petHunger
                ))
            end
        end
        -- Add helpful information at the bottom
        display:cecho(tabName, "\n<grey>Commands: summon <pet>, feed <pet>, dismiss <pet>")
    end)
end
