function ui.updatePetDisplay()
	-- Check if pets data is available
	if not ui.hasGmcpData("Char", "Inventory", "Pets") then
		ui.updateDisplay("eqDisplay", "Pets", function(display, tabName)
			display:cecho(tabName, "\nPets are not implemented yet here.")
		end)
		return
	end

	ui.updateDisplay("eqDisplay", "Pets", function(display, tabName)
		display:cecho(tabName, "<green>" .. string.format("%-15s", "Companions"))
		display:cecho(tabName, "<cyan>Right-click to look or remove\n")

		-- Helper function to display pet/companion
		local function displayCompanion(label, item)
			display:cecho(tabName, "\n<sandy_brown>" .. string.format("%-15s", label))

			if not item or item == "" then
				display:cecho(tabName, "<red>---")
			else
				local itemName = (type(item) == "table" and item.name) or "Unknown Companion"
				local itemId = (type(item) == "table" and item.id) or "?"

				display:cechoPopup(tabName, "<reset>" .. itemName .. " <gray>[" .. itemId .. "]", {
					string.format([[send("look %s", false)]], itemId),
					string.format([[send("remove %s", false)]], itemId),
				}, {
					"Look at " .. itemName,
					"Remove " .. itemName,
				}, true)
			end
		end

		-- Display Leading
		local leading = ui.getGmcpData("", "Char", "Inventory", "Pets", "leading")
		displayCompanion("Leading", leading)

		-- Display Mount
		local mount = ui.getGmcpData("", "Char", "Inventory", "Pets", "mount")
		displayCompanion("Mount", mount)

		-- Display Pets (list of multiple pets)
		display:cecho(tabName, "\n<sandy_brown>" .. string.format("%-15s", "Pets"))
		local petsList = ui.getGmcpData({}, "Char", "Inventory", "Pets", "pets")

		if #petsList == 0 then
			display:cecho(tabName, "<red>---")
		else
			for _, pet in ipairs(petsList) do
				display:cecho(tabName, "\n") -- separate lines for each pet
				local itemName = pet.name or "Unknown Pet"
				local itemId = pet.id or "?"

				display:cechoPopup(tabName, "<reset>" .. itemName .. " <gray>[" .. itemId .. "]", {
					string.format([[send("look %s", false)]], itemId),
					string.format([[send("remove %s", false)]], itemId),
				}, {
					"Look at " .. itemName,
					"Remove " .. itemName,
				}, true)
			end
		end
	end)
end
