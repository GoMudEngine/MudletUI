function ui.updateEQDisplay()
	ui.updateDisplay("eqDisplay", "Equipment", function(display, tabName)
		-- Always show header
		display:cecho(tabName, ui.createHeader("Equipment", "Worn Items", display:get_width()) .. "\n")
		display:cecho(tabName, "<green>" .. string.format("%-11s", "Location"))
		display:cecho(tabName, "<cyan>R/C to look or remove\n")
		
		-- Check if we have inventory data
		if not ui.hasGmcpData("Char", "Inventory") then
			-- Show default equipment slots with empty values
			local defaultSlots = {
				"head", "neck", "torso", "arms", "hands",
				"finger", "waist", "legs", "feet", "wielded"
			}
			for _, slot in ipairs(defaultSlots) do
				display:cecho(tabName, "\n<snow>" .. string.format("%-11s", ui.titleCase(slot)))
				display:cecho(tabName, "<red>---")
			end
			display:cecho(tabName, "\n\n<grey>Waiting for equipment data...")
			return
		end

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
