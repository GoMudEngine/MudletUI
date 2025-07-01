function ui.updateCombatStatusGauge()
	if not ui.hasGmcpData("Char", "CombatStatus") then
		if ui.balGauge then
			ui.balGauge:setValue(1, 1, "Ready")
		end
		return
	end

	local status = gmcp.Char.CombatStatus
	local cooldown = status.cooldown or 0
	local maxCooldown = status.max_cooldown or 0
	local nameIdle = status.name_idle or "Ready"
	local nameActive = status.name_active or "Cooldown"

	if tonumber(cooldown) > 0 and maxCooldown > 0 then
		-- Show cooldown progress
		local currentCooldown = maxCooldown - cooldown
		local text = string.format("%s", cooldown)
		ui.balGauge:setValue(currentCooldown, maxCooldown, text)
	else
		-- Show ready state
		ui.balGauge:setValue(1, 1, nameIdle)
		-- Raise an event we can hook into if something needs to happen on regaining readiness
		raiseEvent("ui.charCooldownReady")
	end
end
