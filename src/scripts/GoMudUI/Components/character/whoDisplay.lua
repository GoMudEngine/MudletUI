function ui.updateWhoDisplay()
	if not ui.hasGmcpData("Game", "Who", "Players") then
		return
	end

	ui.updateDisplay("charDisplay", "Wholist", function(display, tabName)
		local players = ui.getGmcpData({}, "Game", "Who", "Players")
		local playerCount = #players

		-- Create header
		local header = ui.createHeader("Online players", tostring(playerCount), display:get_width())
		display:cecho(tabName, header .. "\n")

		-- Build player list
		local playerNames = {}
		for _, player in ipairs(players) do
			table.insert(playerNames, "<forest_green>" .. player.name)
		end

		-- Display player names
		display:cecho(tabName, table.concat(playerNames, ", "))
	end)
end
