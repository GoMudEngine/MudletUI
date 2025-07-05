function ui.updatePlayerGauges()
	-- Check if gauge manager is initialized
	if not ui.gaugeManager then
		return
	end
	
	-- Use the gauge manager to update all player gauges
	ui.gaugeManager.updatePlayerGauges()
end
