function ui.updateCharDisplay()
    -- Check if required GMCP data is available
    if not ui.hasGmcpData("Char", "Info") or not ui.hasGmcpData("Char", "Worth") then
        return
    end

    -- Extract character info with defaults
    local name = ui.getGmcpData("None", "Char", "Info", "name")
    local race = ui.titleCase(ui.getGmcpData("none", "Char", "Info", "race"))
    local class = ui.titleCase(ui.getGmcpData("none", "Char", "Info", "class"))
    local alignment = ui.titleCase(ui.getGmcpData("none", "Char", "Info", "alignment"))
    local level = ui.getGmcpData(1, "Char", "Info", "level")

    -- Use the update display utility
    ui.updateDisplay("charDisplay", "Character", function(display, tabName)
        -- Header with centered formatting
        local headerText = string.format("<dodger_blue>%s<white> Lvl<gold>: <dodger_blue>%s", name, level)
        display:cecho(tabName, ui.createHeader("Name", headerText, display:get_width()))

        display:cecho(tabName, "\n")
        display:cecho(tabName, "<white>Race<gold>: <grey>" .. race .. "  <cyan>Class<gold>: <grey>" .. class)
        display:cecho(tabName, "\n")
        display:cecho(tabName, "<white>Alignment<gold>: <grey>" .. alignment)
        display:cecho(tabName, "\n\n")

        -- Stats section (if available)
        if ui.hasGmcpData("Char", "Stats") then
            -- Worth points
            local skillPoints = ui.getGmcpData("0", "Char", "Worth", "skillpoints")
            local trainingPoints = ui.getGmcpData("0", "Char", "Worth", "trainingpoints")

            display:cecho(tabName,
                "<SeaGreen>Skill Points<white>: <white>" .. skillPoints ..
                "  <DodgerBlue>Training Points<white>: <white>" .. trainingPoints
            )
            display:cecho(tabName, "\n\n")

            -- Stats display (paired for better layout)
            local mysticism = ui.getGmcpData(0, "Char", "Stats", "mysticism")
            local perception = ui.getGmcpData(0, "Char", "Stats", "perception")
            local smarts = ui.getGmcpData(0, "Char", "Stats", "smarts")
            local speed = ui.getGmcpData(0, "Char", "Stats", "speed")
            local strength = ui.getGmcpData(0, "Char", "Stats", "strength")
            local vitality = ui.getGmcpData(0, "Char", "Stats", "vitality")

            display:cecho(tabName,
                "<SkyBlue>Mysticism<white>: <gold>" .. string.format("%2d", mysticism) ..
                "    <SkyBlue>Perception<white>:    <gold>" .. string.format("%2d", perception)
            )
            display:cecho(tabName, "\n")

            display:cecho(tabName,
                "<SkyBlue>Smarts<white>:    <gold>" .. string.format("%2d", smarts) ..
                "    <SkyBlue>Speed<white>:         <gold>" .. string.format("%2d", speed)
            )
            display:cecho(tabName, "\n")

            display:cecho(tabName,
                "<SkyBlue>Strength<white>:  <gold>" .. string.format("%2d", strength) ..
                "    <SkyBlue>Vitality<white>:      <gold>" .. string.format("%2d", vitality)
            )
        end
    end)
end
