function ui.updateEQDisplay()
	if not ui.hasGmcpData("Char", "Inventory") then
		return
	end

	ui.updateDisplay("eqDisplay", "Equipment", function(display, tabName)
		display:cecho(tabName, "<green>" .. string.format("%-11s", "Location"))
		display:cecho(tabName, "<cyan>R/C to look or remove\n")

		-- Get all locations from Worn inventory
		local locations = {}
		local worn = ui.getGmcpData({}, "Char", "Inventory", "Worn")
		for location, _ in pairs(worn) do
			table.insert(locations, location)
		end

		-- Sort locations alphabetically
		table.sort(locations)

		for _, slot in ipairs(locations) do
			local item = nil

			-- Check Wielded first
			local wielded = ui.getGmcpData({}, "Char", "Inventory", "Wielded")
			if wielded[slot] and wielded[slot].name ~= "-nothing-" then
				item = wielded[slot]
			elseif worn[slot] and worn[slot].name ~= "-nothing-" then
				-- Check Worn if not wielded
				item = worn[slot]
			end

			-- Display the slot name
			display:cecho(tabName, "\n<snow>" .. string.format("%-11s", ui.titleCase(slot)))

			if not item then
				display:cecho(tabName, "<red>---")
			else
				local itemName = ui.titleCase(item.name)
				display:cechoPopup(tabName, "<sandy_brown>" .. itemName, {
					string.format([[send("look %s", false)]], item.id),
					string.format([[send("remove %s", false)]], item.id),
				}, {
					"Look at " .. itemName,
					"Remove " .. itemName,
				}, true)
			end
		end
	end)
end
