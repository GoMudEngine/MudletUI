function ui.createPlayerGuages()
	-- Set all the styles needed for the gauges
	local gaugeBorder = "border-radius: 3px;border: 1px solid rgba(160, 160, 160, 50%);"

	ui.styles = {
		gaugeText = f([[{ui.cssFont} qproperty-alignment: 'AlignRight|AlignVCenter';]]),

		HPGaugeFront = f([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(150, 25, 25), stop: 0.1 rgb(180,0,0), stop: 0.85 rgb(155,0,0), stop: 1 rgb(130,0,0)); {gaugeBorder}]]),
		HPGaugeBack = f([[background-color: rgb(60, 0, 0); {gaugeBorder}]]),

		SPGaugeFront = f([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(127, 0, 87), stop: 0.1 rgb(147, 0, 107), stop: 0.85 rgb(117, 0, 77), stop: 1 rgb(117, 0, 67)); {gaugeBorder}]]),
		SPGaugeBack = f([[background-color: rgb(60, 0, 60); {gaugeBorder}]]),

		balanceGaugeFront = f([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(25, 25, 150), stop: 0.1 rgb(0,0,180), stop: 0.85 rgb(0,0,155), stop: 1 rgb(0,0,130)); {gaugeBorder}]]),
		balanceGaugeBack = f([[background-color: rgb(0, 0, 60); {gaugeBorder}]]),

		vitalsLabel = f([[font-weight: 400; padding-left: 2px; background-color: rgba(0,0,0,0%); {ui.settings.cssFont}]]),
		balanceLabel = f([[font-weight: 200; qproperty-alignment: 'AlignRight|AlignVCenter'; background-color: rgba(0,0,0,0%); {ui.cssFont}]]),

		enemyGaugeFront = f([[{ui.settings.cssFont} background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(150, 25, 25), stop: 0.1 rgb(180,0,0), stop: 0.85 rgb(155,0,0), stop: 1 rgb(130,0,0)); {gaugeBorder}]]),
		enemyGaugeBack = f([[background-color: rgb(60, 0, 0); {gaugeBorder}]]),
	}

	-- Create the HP gauge using the factory function
	ui.hpGauge = ui.createGauge("HP", {
		name = "hpGauge",
		x = 10,
		y = 0,
		width = 250,
		height = 20,
		font = ui.settings.consoleFont,
	}, ui.gaugeDisplay)

	-- Create HP label
	ui.hpLabel = Geyser.Label:new({
		name = "hpLabel",
		x = 5,
		y = 0,
		width = 250,
		height = 20,
		message = "HP",
	}, ui.hpGauge)
	ui.hpLabel:setStyleSheet(ui.styles.vitalsLabel)
	ui.hpLabel:setFontSize(ui.settings.gaugeFontSize)

	-- Create the SP gauge using the factory function
	ui.spGauge = ui.createGauge("SP", {
		name = "spGauge",
		x = 10,
		y = 30,
		width = 250,
		height = 20,
	}, ui.gaugeDisplay)

	-- Create SP label
	ui.spLabel = Geyser.Label:new({
		name = "spLabel",
		x = 5,
		y = 0,
		width = 250,
		height = 20,
		message = "SP",
	}, ui.spGauge)
	ui.spLabel:setStyleSheet(ui.styles.vitalsLabel)
	ui.spLabel:setFontSize(ui.settings.gaugeFontSize)

	-- Create the Balance gauge using the factory function
	ui.balGauge = ui.createGauge("balance", {
		name = "balGauge",
		x = 270,
		y = 30,
		width = 250,
		height = 20,
	}, ui.gaugeDisplay)

	-- Create the Enemy HP gauge using the factory function
	ui.enemyGauge = ui.createGauge("enemy", {
		name = "enemyGauge",
		x = 270,
		y = 0,
		width = 250,
		height = 20,
	}, ui.gaugeDisplay)

	-- Create enemy label
	ui.enemyLabel = Geyser.Label:new({
		name = "enemyLabel",
		x = 5,
		y = 0,
		width = "100%",
		height = "100%",
	}, ui.enemyGauge)
	ui.enemyLabel:setStyleSheet(ui.styles.vitalsLabel)
	ui.enemyLabel:setFontSize(ui.settings.gaugeFontSize)
end

-- Helper function to create gauge labels
function ui.createGaugeLabel(name, message, parent)
	local label = Geyser.Label:new({
		name = name,
		x = 5,
		y = 0,
		width = parent == ui.enemyGauge and "100%" or 250,
		height = parent == ui.enemyGauge and "100%" or 20,
		message = message or "",
	}, parent)
	
	label:setStyleSheet(ui.styles.vitalsLabel)
	label:setFontSize(ui.settings.gaugeFontSize)
	
	return label
end