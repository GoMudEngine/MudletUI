function ui.updateCombatDisplay()
	if not ui.hasGmcpData("Char", "CombatStatus") then
		return
	end

	local status = ui.getGmcpData(nil, "Char", "CombatStatus")
	
	-- Check if in combat
	if not status.in_combat then
		ui.updateDisplay("roomDisplay", "Combat", function(display, tabName)
			display:cecho(tabName, "<grey> Not engaged in combat")
		end)
		-- Switch back to Room tab when combat ends
		ui.roomDisplay:switchTab("Room")
		return
	end

	-- In combat
	ui.roomDisplay:switchTab("Combat")
	ui.updateDisplay("roomDisplay", "Combat", function(display, tabName)
		-- Display combat status
		display:cecho(tabName, "<grey>Combat Style<white>: <gold>" .. (status.combat_style or "unknown") .. "\n")
		
		-- Display primary target
		if status.target and status.target ~= "None" and status.target ~= "" then
			display:cecho(tabName, "\n<grey>Target<white>:\n")
			
			local targetName = status.target
			local hp_current = tonumber(status.target_hp_current) or 0
			local hp_max = tonumber(status.target_hp_max) or 0
			
			if hp_current > 0 and hp_max > 0 then
				local nameLength = string.len(targetName)
				local hpLength = string.len(tostring(hp_current))
				local maxHpLength = string.len(tostring(hp_max))
				local padding = math.max(1, 35 - nameLength - hpLength - maxHpLength)

				display:cecho(
					tabName,
					string.format(
						"<red>%s%s<gold>%s<white>/<gold>%s\n",
						targetName,
						string.rep(" ", padding),
						hp_current,
						hp_max
					)
				)
			else
				display:cecho(tabName, "<red>" .. targetName .. "\n")
			end
		else
			display:cecho(tabName, "\n<grey>Target<white>:\n")
			display:cecho(tabName, "<red>none\n")
		end
		
		-- Display balance/cooldown status
		display:cecho(tabName, "\n<grey>Status<white>: ")
		local cooldown = tonumber(status.cooldown) or 0
		if cooldown > 0 then
			display:cecho(tabName, "<yellow>" .. status.name_active .. " (" .. cooldown .. "s)\n")
		else
			display:cecho(tabName, "<green>" .. status.name_idle .. "\n")
		end

		-- Display other enemies if we have them
		local enemies = ui.getGmcpData(nil, "Char", "Enemies")
		if enemies and #enemies > 1 then
			display:cecho(tabName, "\n<grey>Other Hostiles<white>:\n")
			for k, enemy in pairs(enemies) do
				if k > 1 then
					local hp = tonumber(enemy.hp) or 0
					local maxhp = tonumber(enemy.maxhp) or 0
					local nameLength = string.len(enemy.name)
					local hpLength = string.len(tostring(hp))
					local maxHpLength = string.len(tostring(maxhp))
					local padding = math.max(1, 35 - nameLength - hpLength - maxHpLength)

					display:cecho(
						tabName,
						string.format(
							"<red>%s%s<gold>%s<white>/<gold>%s\n",
							enemy.name,
							string.rep(" ", padding),
							hp,
							maxhp
						)
					)
				end
			end
		end
	end)
end
