function ui.updateDisplays(args)
    args = args or {}

    -- If manually triggered, refresh GMCP data first
    if args.refreshGMCP then
        sendGMCP("GMCP SendFullPayload")
    end

    local function safeUpdate(funcName, func)
        local success, err = pcall(func)
        if not success then
            echo("ERROR in " .. funcName .. ": " .. tostring(err) .. "\n")
        end
    end

    safeUpdate("updatePromptDisplay", ui.updatePromptDisplay)
    safeUpdate("updateEQDisplay", ui.updateEQDisplay)
    safeUpdate("updateInvDisplay", ui.updateInvDisplay)
    safeUpdate("updatePetDisplay", ui.updatePetDisplay)
    safeUpdate("updateRoomDisplay", ui.updateRoomDisplay)
    safeUpdate("updateEnemyGauge", ui.updateEnemyGauge)
    safeUpdate("updateCombatStatusGauge", ui.updateCombatStatusGauge)
    safeUpdate("updatePlayerGauges", ui.updatePlayerGauges)
    safeUpdate("updateChannelDisplay", ui.updateChannelDisplay)
    safeUpdate("updateCharDisplay", ui.updateCharDisplay)
    safeUpdate("updateWhoDisplay", ui.updateWhoDisplay)
    safeUpdate("updatePromptRightDisplay", ui.updatePromptRightDisplay)
    safeUpdate("updateAffectsDisplay", ui.updateAffectsDisplay)
    safeUpdate("updateGroupDisplay", ui.updateGroupDisplay)
    safeUpdate("updateTopBar", ui.updateTopBar)
    safeUpdate("updateCombatDisplay", ui.updateCombatDisplay)
    safeUpdate("resizeEvent", ui.resizeEvent)

    raiseWindow("mapper")
end
