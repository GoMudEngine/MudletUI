function ui.createPlayerGuages()
	-- Check if gaugeDisplay exists
	if not ui.gaugeDisplay then
		ui.displayUIMessage("ERROR: ui.gaugeDisplay is nil - gauges cannot be created")
		return
	end
	
	-- Initialize the gauge management system with all gauges
	ui.gaugeManager.initialize(ui.gaugeDisplay)
end
