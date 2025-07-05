function ui.updateCharDisplay()
	-- Show default values if no GMCP data
	local hasCharInfo = ui.hasGmcpData("Char", "Info")
	local hasWorth = ui.hasGmcpData("Char", "Worth")

	-- Extract character info with defaults
	local name = hasCharInfo and ui.getGmcpData("Unknown", "Char", "Info", "name") or "Unknown"
	local race = hasCharInfo and ui.titleCase(ui.getGmcpData("unknown", "Char", "Info", "race")) or "Unknown"
	local class = hasCharInfo and ui.titleCase(ui.getGmcpData("unknown", "Char", "Info", "class")) or "Unknown"
	local alignment = hasCharInfo and ui.titleCase(ui.getGmcpData("neutral", "Char", "Info", "alignment")) or "Neutral"
	local level = hasCharInfo and ui.getGmcpData(1, "Char", "Info", "level") or 1

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
			-- Worth points with defaults
			local skillPoints = hasWorth and tonumber(ui.getGmcpData("0", "Char", "Worth", "skillpoints")) or 0
			local trainingPoints = hasWorth and tonumber(ui.getGmcpData("0", "Char", "Worth", "trainingpoints")) or 0

			display:cecho(
				tabName,
				"<SeaGreen>Skill Points<white>: <white>"
					.. skillPoints
					.. "  <DodgerBlue>Training Points<white>: <white>"
					.. trainingPoints
			)
			display:cecho(tabName, "\n\n")

			-- Stats display (paired for better layout)
			local mysticism = tonumber(ui.getGmcpData(0, "Char", "Stats", "mysticism")) or 0
			local perception = tonumber(ui.getGmcpData(0, "Char", "Stats", "perception")) or 0
			local smarts = tonumber(ui.getGmcpData(0, "Char", "Stats", "smarts")) or 0
			local speed = tonumber(ui.getGmcpData(0, "Char", "Stats", "speed")) or 0
			local strength = tonumber(ui.getGmcpData(0, "Char", "Stats", "strength")) or 0
			local vitality = tonumber(ui.getGmcpData(0, "Char", "Stats", "vitality")) or 0

			display:cecho(
				tabName,
				"<SkyBlue>Mysticism<white>: <gold>"
					.. string.format("%2d", mysticism)
					.. "    <SkyBlue>Perception<white>:    <gold>"
					.. string.format("%2d", perception)
			)
			display:cecho(tabName, "\n")

			display:cecho(
				tabName,
				"<SkyBlue>Smarts<white>:    <gold>"
					.. string.format("%2d", smarts)
					.. "    <SkyBlue>Speed<white>:         <gold>"
					.. string.format("%2d", speed)
			)
			display:cecho(tabName, "\n")

			display:cecho(
				tabName,
				"<SkyBlue>Strength<white>:  <gold>"
					.. string.format("%2d", strength)
					.. "    <SkyBlue>Vitality<white>:      <gold>"
					.. string.format("%2d", vitality)
			)
		end
	end)
end
