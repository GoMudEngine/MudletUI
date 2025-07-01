function ui.updateGroupDisplay()
	ui.updateDisplay("affectsDisplay", "Group", function(display, tabName)
		-- Create header
		local header = ui.createHeader("Group Name", "<DodgerBlue>None", display:get_width())
		display:cecho(tabName, header)
		display:cecho(tabName, "\n\n")
		display:cecho(tabName, "<reset>Once we have group information for the UI it will go here.")
	end)
end
