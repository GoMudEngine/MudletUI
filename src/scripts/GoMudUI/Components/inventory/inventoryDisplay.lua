function ui.updateInvDisplay()
	ui.updateDisplay("eqDisplay", "Inventory", function(display, tabName)
		-- Always show header
		display:cecho(tabName, ui.createHeader("Inventory", "Backpack", display:get_width()) .. "\n")
		display:cecho(tabName, "<cyan>R/C to look, drop or wear")
		display:cecho(tabName, "\n\n")
		
		-- Check if we have inventory data
		if not ui.hasGmcpData("Char", "Inventory", "Backpack", "items") then
			display:cecho(tabName, "\n  <sandy_brown>You are not carrying anything.")
			display:cecho(tabName, "\n\n<grey>Waiting for inventory data...")
			return
		end

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
