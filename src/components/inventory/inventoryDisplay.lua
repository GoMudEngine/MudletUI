function ui.updateInvDisplay()
	if not ui.hasGmcpData("Char", "Inventory", "Backpack", "items") then
		return
	end

	ui.updateDisplay("eqDisplay", "Inventory", function(display, tabName)
		display:cecho(tabName, "<cyan>R/C to look, drop or wear")
		display:cecho(tabName, "\n\n")

		local backpackItems = ui.getGmcpData({}, "Char", "Inventory", "Backpack", "items")

		if #backpackItems > 0 then
			for _, item in ipairs(backpackItems) do
				local itemName = ui.titleCase(item.name)
				display:cechoPopup(tabName, "<sandy_brown>  " .. itemName .. "\n", {
					string.format([[send("look %s", false)]], item.id),
					string.format([[send("drop %s", false)]], item.id),
					string.format([[send("wear %s", false)]], item.id),
				}, {
					"Look at " .. itemName,
					"Drop " .. itemName,
					"Wear " .. itemName,
				}, true)
			end
		else
			display:cecho(tabName, "\n  <sandy_brown>You are not carrying anything.")
		end
	end)
end
