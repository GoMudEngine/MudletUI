function ui.updateGroupDisplay()
    ui.eqDisplay:clear("Group")

    -- Check if we have party data
    if not gmcp.Party or not gmcp.Party.Info then
        ui.eqDisplay:cecho("Group", "<grey>Not in a group")
        return
    end

    local party = gmcp.Party.Info
    local vitals = gmcp.Party.Vitals or {}

    -- Display party header
    local leaderName = party.leader or "None"

    -- Count party members
    local partySize = 0
    if party.members and type(party.members) == "table" then
        partySize = #party.members
    end

    -- Display leader and party size info
    ui.eqDisplay:cecho("Group",
        string.format("<white>Leader: <gold>%s    <white>Party Size: <green>%d\n\n", leaderName, partySize))

    -- Calculate column widths
    local totalWidth = math.floor(ui.eqDisplay:get_width() / ui.consoleFontWidth)
    local lvlWidth = 5                                        -- "(XX)"
    local healthWidth = 5                                     -- "XXX%"
    local nameWidth = totalWidth - lvlWidth - healthWidth + 2 -- Add 2 for spacing (was -2)

    -- Display headers
    ui.eqDisplay:cecho("Group",
        string.format("<white>%-" .. lvlWidth .. "s%-" .. (nameWidth - 2) .. "s%" .. (healthWidth) .. "s\n",
            "Lvl", "Name", "Health"))
    ui.eqDisplay:cecho("Group",
        "<grey>" .. string.rep("-", math.floor(ui.eqDisplay:get_width() / ui.consoleFontWidth)) .. "\n")

    -- Display party members if available
    if party.members and type(party.members) == "table" and #party.members > 0 then
        for _, member in ipairs(party.members) do
            local memberName = ""
            local memberStatus = ""

            -- Handle both string and object member formats
            if type(member) == "string" then
                memberName = member
            elseif type(member) == "table" and member.name then
                memberName = member.name
                memberStatus = member.status or ""
            end

            if memberName ~= "" then
                -- Check if we have vitals for this member
                local memberVitals = vitals[memberName]
                if memberVitals then
                    local hp = memberVitals.health or 0 -- Already a percentage
                    local level = memberVitals.level or 0

                    -- Color code based on status
                    local nameColor = "<green>"
                    if memberStatus == "leader" then
                        nameColor = "<gold>"
                    end

                    -- Format level
                    local lvlText = string.format("(%2d)", level)

                    -- Format HP as percentage
                    local hpText = string.format("%3d%%", hp)

                    -- Format the line
                    ui.eqDisplay:cecho("Group",
                        string.format(
                            "<grey>%-" .. lvlWidth .. "s%s%-" .. (nameWidth - 2) .. "s<white>%" .. healthWidth .. "s\n",
                            lvlText, nameColor, memberName, hpText))
                else
                    ui.eqDisplay:cecho("Group",
                        string.format("<grey>( ?)<green>%-" .. (nameWidth + 2) .. "s<grey>%" .. healthWidth .. "s\n",
                            memberName, "--"))
                end
            end
        end
    elseif party.members then
        -- Handle userdata or other non-table types
        ui.eqDisplay:cecho("Group", "<grey>Member data not available\n")
    end

    -- Display invited members if any
    if party.invited and type(party.invited) == "table" and #party.invited > 0 then
        ui.eqDisplay:cecho("Group", "\n<yellow>Invited:\n")
        for _, invited in ipairs(party.invited) do
            local invitedName = ""

            -- Handle both string and object invited formats
            if type(invited) == "string" then
                invitedName = invited
            elseif type(invited) == "table" and invited.name then
                invitedName = invited.name
            end

            if invitedName ~= "" then
                -- Check if we have vitals for invited member
                local invitedVitals = vitals[invitedName]
                if invitedVitals then
                    local hp = invitedVitals.health or 0 -- Already a percentage
                    local level = invitedVitals.level or 0

                    -- Format level
                    local lvlText = string.format("(%2d)", level)

                    -- Format HP as percentage
                    local hpText = string.format("%3d%%", hp)

                    -- Format the line
                    ui.eqDisplay:cecho("Group",
                        string.format(
                            "<grey>%-" ..
                            lvlWidth .. "s<yellow>%-" .. (nameWidth - 2) .. "s<white>%" .. healthWidth .. "s\n",
                            lvlText, invitedName, hpText))
                else
                    ui.eqDisplay:cecho("Group",
                        string.format("<grey>( ?)<yellow>%-" .. (nameWidth + 2) .. "s<grey>%" .. healthWidth .. "s\n",
                            invitedName, "pending"))
                end
            end
        end
    end
end
