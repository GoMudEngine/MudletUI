function ui.showTempAffects(name, duration, isBuff)
    local name = name
    local duration = tonumber(duration) or 0
    local isBuff = isBuff

    local time, timeLen
    if duration < 0 then
        -- Permanent affect, show "--"
        time = "--"
        timeLen = "--"
    else
        local h, m, s = shms(duration)
        if tonumber(h) > 0 then
            h = h .. "<DodgerBlue>h<white> "
            s = ""
        else
            h = ""
            s = " " .. s .. "<gold>s"
        end

        if tonumber(m) > 0 then m = m .. "<SkyBlue>m<white>" else m = "" end
        time = h .. m .. s
        timeLen = time:gsub("<%w+:?%w*>", "")
    end
    local color = ""

    if isBuff then
        color = "<SpringGreen>"
    else
        color = "<red>"
    end

    local affect = color ..
        name ..
        string.rep(" ", 28 - string.len(name)) ..
        string.rep(" ",
            math.ceil(ui.affectsDisplay:get_width() / ui.consoleFontWidth) - 20 - string.len(name) -
            (4 - string.len(name)) -
            string.len(timeLen) - 6) .. "<white>" .. time

    return affect
end

function ui.updateAffectsDisplay()
    if gmcp.Char == nil or gmcp.Char.Affects == nil then
        ui.affectsDisplay:clear("Affects")
        ui.affectsDisplay:cecho("Affects", "\nAffects are not implemented yet here.")
        return
    end

    ui.affectsTable = {
        buff = {
            permanent = {},
            timed = {}
        },
        debuff = {
            permanent = {},
            timed = {}
        }
    }

    ui.affectsDisplay:clear("Affects")

    ui.affectsDisplay:cecho("Affects",
        "<white>Affected by:" ..
        string.rep(" ", math.floor(ui.affectsDisplay:get_width() / (ui.consoleFontWidth)) - 22) .. "Duration: ")
    ui.affectsDisplay:cecho("Affects", "\n")
    ui.affectsDisplay:cecho("Affects",
        "<grey>" .. string.rep("-", math.floor(ui.affectsDisplay:get_width() / ui.consoleFontWidth)) .. "\n")

    local haveBuff = false

    -- Process all affects
    for _, affect in pairs(gmcp.Char.Affects) do
        local isBuff = affect.type ~= "debuff"
        local isPermanent = tonumber(affect.duration_current or 0) < 0

        if isBuff then
            haveBuff = true
            if isPermanent then
                table.insert(ui.affectsTable.buff.permanent,
                    { name = affect.name, description = affect.description or "" })
            else
                table.insert(ui.affectsTable.buff.timed,
                    {
                        display = ui.showTempAffects(affect.name, affect.duration_current, true),
                        name = affect.name,
                        description = affect
                            .description or ""
                    })
            end
        else
            if isPermanent then
                table.insert(ui.affectsTable.debuff.permanent,
                    { name = affect.name, description = affect.description or "" })
            else
                table.insert(ui.affectsTable.debuff.timed,
                    {
                        display = ui.showTempAffects(affect.name, affect.duration_current, false),
                        name = affect.name,
                        description = affect
                            .description or ""
                    })
            end
        end
    end

    -- Show permanent positive affects
    for _, affect in pairs(ui.affectsTable.buff.permanent) do
        local lineContent = "<SkyBlue>" ..
            affect.name ..
            string.rep(" ", math.floor(ui.affectsDisplay:get_width() / ui.consoleFontWidth) - string.len(affect.name) - 3) ..
            "<gold>-- \n"
        ui.affectsDisplay:cechoPopup("Affects", lineContent, {}, { affect.name .. "\n" .. affect.description }, true)
    end

    -- Show temporary positive effects
    for _, affect in pairs(ui.affectsTable.buff.timed) do
        ui.affectsDisplay:cechoPopup("Affects", affect.display .. "\n", {}, { affect.name .. "\n" .. affect.description },
            true)
    end

    if haveBuff then ui.affectsDisplay:echo("Affects", "\n") end

    -- Show permanent negative affects
    for _, affect in pairs(ui.affectsTable.debuff.permanent) do
        local lineContent = "<red>" ..
            affect.name ..
            string.rep(" ", math.floor(ui.affectsDisplay:get_width() / ui.consoleFontWidth) - string.len(affect.name) - 3) ..
            "<gold>-- \n"
        ui.affectsDisplay:cechoPopup("Affects", lineContent, {}, { affect.name .. "\n" .. affect.description }, true)
    end

    -- Show temporary negative effects
    for _, affect in pairs(ui.affectsTable.debuff.timed) do
        ui.affectsDisplay:cechoPopup("Affects", affect.display .. "\n", {}, { affect.name .. "\n" .. affect.description },
            true)
    end
end
