function ui.updateTopBar()
	ui.updateDisplay("topDisplay", nil, function(display)
		local parts = {}

		-- UI Version
		display:cecho("<DarkSeaGreen>GoMud UI version<white>: ")
		display:cechoLink(
			"<SkyBlue><u>" .. ui.version .. "</u>",
			[[ui.gomudUIShowFullChangelog()]],
			"Show the GoMud UI changelog",
			true
		)

		-- Mapper Version
		if ui.getGmcpData(nil, "mmp", "version") then
			display:echo("  ")
			display:cecho("<DarkSeaGreen>Mapper Version<white>: <SkyBlue>" .. mmp.version)
		end

		-- Crowdmap Version
		if ui.crowdmapVersion then
			display:echo("  ")
			display:cecho("<DarkSeaGreen>Crowdmap Version<white>: ")
			display:cechoLink(
				"<SkyBlue><u>" .. ui.crowdmapVersion .. "</u>",
				[[mmp.showcrowdchangelog()]],
				"Show the crowdmap changelog",
				true
			)
		end

		-- Connection Time
		if ui.hasGmcpData("Game", "Info", "logintime") then
			local loginTime = ui.getGmcpData(nil, "Game", "Info", "logintime")
			local timeElapsed = ui.getTimeElapsed(loginTime)
			display:echo("  ")
			display:cecho("<DarkSeaGreen>Connection Time<white>: <SkyBlue>" .. timeElapsed)
		end
	end)
end
