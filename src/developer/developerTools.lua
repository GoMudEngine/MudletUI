-- Developer Tools and Debugging Utilities
-- Provides tools for debugging and inspecting the UI system

ui = ui or {}
ui.dev = ui.dev or {}
ui.dev.monitors = ui.dev.monitors or {}

-- Enable/disable developer mode
ui.dev.enabled = false

-- Utility function for table size if it doesn't exist
if not table.size then
	table.size = function(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end
end

-- GMCP event monitoring
ui.dev.gmcpMonitor = {
	enabled = false,
	filter = nil,
	log = {},
	maxLogSize = 100,
}

-- Performance tracking
ui.dev.performance = {
	enabled = false,
	updates = {},
	slowThreshold = 50, -- milliseconds
}

-- Enable developer mode
function ui.dev.enable()
	ui.dev.enabled = true
	ui.displayUIMessage("Developer mode <green>enabled<reset>")

	-- Create developer display if it doesn't exist
	if not ui.devDisplay then
		ui.dev.createDevDisplay()
	end
end

-- Disable developer mode
function ui.dev.disable()
	ui.dev.enabled = false
	ui.displayUIMessage("Developer mode <red>disabled<reset>")

	-- Hide developer display
	if ui.devDisplay then
		ui.devDisplay:hide()
	end
end

-- Create developer display window
function ui.dev.createDevDisplay()
	-- Create a floating window for developer tools
	ui.devWindow = Geyser.UserWindow:new({
		name = "ui.devWindow",
		titleText = "GoMud UI Developer Tools",
		x = "10%",
		y = "10%",
		width = "600px",
		height = "400px",
	})

	-- Create EMCO for different dev tabs
	ui.devDisplay = EMCO:new({
		name = "ui.devDisplay",
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		fontSize = 10,
		font = ui.settings.consoleFont,
		tabFont = ui.settings.consoleFont,
		tabFontSize = 10,
		tabHeight = 20,
		gap = 1,
		consoleColor = ui.settings.consoleBackgroundColor,
		tabBoxColor = ui.settings.tabBarColor,
		activeTabFGColor = "white",
		inactiveTabFGColor = "gray",
		activeTabCSS = ui.getStyle("tabs", "active"),
		inactiveTabCSS = ui.getStyle("tabs", "inactive"),
		consoles = { "Inspector", "GMCP Monitor", "Performance", "Styles", "Errors", "Help" },
	}, ui.devWindow)

	ui.devDisplay:disableAllLogging()
	ui.dev.updateHelp()
end

-- UI Element Inspector
function ui.dev.inspect(elementName)
	if not ui.dev.enabled then
		ui.displayUIMessage("Developer mode is not enabled. Use 'ui dev enable' first.")
		return
	end

	local element = ui[elementName]
	if not element then
		ui.displayUIMessage("Element not found: " .. elementName)
		return
	end

	ui.devDisplay:clear("Inspector")
	ui.devDisplay:cecho("Inspector", ui.createHeader("Element Inspector", elementName, 600) .. "\n\n")

	-- Get element type
	local elementType = "Unknown"
	if element.type then
		elementType = element.type
	elseif element.container then
		elementType = "Container"
	elseif element.gauge then
		elementType = "Gauge"
	end

	local info = {
		{ "Type", elementType },
		{ "Name", element.name or "N/A" },
		{
			"Position",
			string.format(
				"x: %s, y: %s",
				tostring(element.x or element:get_x() or "N/A"),
				tostring(element.y or element:get_y() or "N/A")
			),
		},
		{
			"Size",
			string.format(
				"w: %s, h: %s",
				tostring(element.width or element:get_width() or "N/A"),
				tostring(element.height or element:get_height() or "N/A")
			),
		},
		{ "Parent", element.container and element.container.name or "Main Window" },
		{ "Visible", element.hidden and "No" or "Yes" },
	}

	-- Display info in a table
	for _, row in ipairs(info) do
		ui.devDisplay:cecho("Inspector", string.format("  <yellow>%-15s<reset>: %s\n", row[1], row[2]))
	end

	-- Show child elements if it's a container
	if element.windowList or element.windows then
		ui.devDisplay:cecho("Inspector", "\n<gold>Child Elements:<reset>\n")
		local children = element.windowList or element.windows
		for name, child in pairs(children) do
			if type(name) == "string" then
				ui.devDisplay:cecho("Inspector", "  - " .. name .. "\n")
			end
		end
	end

	ui.devDisplay:switchTab("Inspector")
end

-- GMCP Monitor
function ui.dev.startGmcpMonitor(filter)
	ui.dev.gmcpMonitor.enabled = true
	ui.dev.gmcpMonitor.filter = filter
	ui.displayUIMessage("GMCP monitor started" .. (filter and " with filter: " .. filter or ""))

	-- Register event handler for all GMCP events
	if not ui.dev.gmcpHandler then
		ui.dev.gmcpHandler = function(event, ...)
			if ui.dev.gmcpMonitor.enabled and event:match("^gmcp%.") then
				ui.dev.logGmcpEvent(event)
			end
		end

		-- Register for common GMCP events
		local gmcpEvents = {
			"gmcp.Char",
			"gmcp.Char.Vitals",
			"gmcp.Char.Status",
			"gmcp.Char.Stats",
			"gmcp.Char.Inventory",
			"gmcp.Char.Affects",
			"gmcp.Char.Worth",
			"gmcp.Room",
			"gmcp.Room.Info",
			"gmcp.Comm.Channel",
			"gmcp.Char.Enemies",
		}

		for _, event in ipairs(gmcpEvents) do
			registerAnonymousEventHandler(event, ui.dev.gmcpHandler)
		end
	end
end

function ui.dev.stopGmcpMonitor()
	ui.dev.gmcpMonitor.enabled = false
	ui.displayUIMessage("GMCP monitor stopped")
end

function ui.dev.logGmcpEvent(event)
	if ui.dev.gmcpMonitor.filter and not event:match(ui.dev.gmcpMonitor.filter) then
		return
	end

	-- Add to log
	local entry = {
		time = os.date("%H:%M:%S"),
		event = event,
		data = ui.dev.getGmcpPath(event:gsub("^gmcp%.", "")),
	}

	table.insert(ui.dev.gmcpMonitor.log, 1, entry)

	-- Trim log if too large
	while #ui.dev.gmcpMonitor.log > ui.dev.gmcpMonitor.maxLogSize do
		table.remove(ui.dev.gmcpMonitor.log)
	end

	-- Update display
	ui.dev.updateGmcpMonitor()
end

function ui.dev.getGmcpPath(path)
	-- Split path by dots
	local parts = {}
	for part in path:gmatch("[^%.]+") do
		table.insert(parts, part)
	end

	local current = gmcp

	for _, part in ipairs(parts) do
		if current and current[part] then
			current = current[part]
		else
			return nil
		end
	end

	return current
end

function ui.dev.updateGmcpMonitor()
	if not ui.devDisplay then
		return
	end

	ui.devDisplay:clear("GMCP Monitor")
	ui.devDisplay:cecho(
		"GMCP Monitor",
		ui.createHeader("GMCP Event Monitor", "Last " .. #ui.dev.gmcpMonitor.log .. " events", 600) .. "\n\n"
	)

	for i, entry in ipairs(ui.dev.gmcpMonitor.log) do
		if i > 20 then
			break
		end -- Show only last 20

		ui.devDisplay:cecho(
			"GMCP Monitor",
			string.format("<gray>%s<reset> <yellow>%s<reset>\n", entry.time, entry.event)
		)

		if entry.data then
			local dataStr = ""
			if type(entry.data) == "table" then
				dataStr = yajl.to_string(entry.data, { indent = "  " })
			else
				dataStr = tostring(entry.data)
			end

			-- Limit data display
			if #dataStr > 200 then
				dataStr = dataStr:sub(1, 200) .. "..."
			end

			ui.devDisplay:cecho("GMCP Monitor", "<gray>" .. dataStr .. "<reset>\n\n")
		end
	end
end

-- Performance monitoring
function ui.dev.trackUpdate(displayName, func)
	if not ui.dev.performance.enabled then
		return func()
	end

	local startTime = getEpoch()
	local result = func()
	local endTime = getEpoch()
	local duration = endTime - startTime

	-- Record the update
	if not ui.dev.performance.updates[displayName] then
		ui.dev.performance.updates[displayName] = {
			count = 0,
			totalTime = 0,
			maxTime = 0,
			slowUpdates = 0,
		}
	end

	local stats = ui.dev.performance.updates[displayName]
	stats.count = stats.count + 1
	stats.totalTime = stats.totalTime + duration
	stats.maxTime = math.max(stats.maxTime, duration)

	if duration > ui.dev.performance.slowThreshold then
		stats.slowUpdates = stats.slowUpdates + 1
		ui.dev.logSlowUpdate(displayName, duration)
	end

	return result
end

function ui.dev.logSlowUpdate(displayName, duration)
	if ui.devDisplay then
		ui.devDisplay:cecho(
			"Performance",
			string.format("<red>SLOW UPDATE<reset>: %s took %dms\n", displayName, duration)
		)
	end
end

function ui.dev.showPerformance()
	if not ui.devDisplay then
		return
	end

	ui.devDisplay:clear("Performance")
	ui.devDisplay:cecho("Performance", ui.createHeader("Performance Monitor", "", 600) .. "\n\n")

	local displayNames = {}
	for name in pairs(ui.dev.performance.updates) do
		table.insert(displayNames, name)
	end
	table.sort(displayNames)

	ui.devDisplay:cecho(
		"Performance",
		string.format("  <yellow>%-20s %8s %8s %8s %8s<reset>\n", "Display", "Count", "Avg(ms)", "Max(ms)", "Slow")
	)
	ui.devDisplay:cecho("Performance", string.rep("-", 70) .. "\n")

	for _, name in ipairs(displayNames) do
		local stats = ui.dev.performance.updates[name]
		local avg = stats.totalTime / stats.count

		local color = avg > ui.dev.performance.slowThreshold and "<red>"
			or avg > ui.dev.performance.slowThreshold / 2 and "<orange>"
			or "<green>"

		ui.devDisplay:cecho(
			"Performance",
			string.format(
				"  %-20s %s%8d %8.1f %8d %8d<reset>\n",
				name,
				color,
				stats.count,
				avg,
				stats.maxTime,
				stats.slowUpdates
			)
		)
	end

	ui.devDisplay:switchTab("Performance")
end

-- Style browser
function ui.dev.showStyles(category)
	if not ui.devDisplay then
		return
	end

	ui.devDisplay:clear("Styles")
	ui.devDisplay:cecho("Styles", ui.createHeader("Style Browser", category or "All Categories", 600) .. "\n\n")

	if category then
		-- Show specific category
		local styles = ui.theme[category]
		if not styles then
			ui.devDisplay:cecho("Styles", "Category not found: " .. category .. "\n")
			return
		end

		for name, style in pairs(styles) do
			ui.devDisplay:cecho("Styles", string.format("<yellow>%s.%s<reset>\n", category, name))

			local styleStr = ""
			if type(style) == "function" then
				local ok, result = pcall(style)
				styleStr = ok and result or "Error: " .. result
			else
				styleStr = tostring(style)
			end

			-- Clean up and indent
			styleStr = styleStr:gsub("\n%s*", "\n    ")
			ui.devDisplay:cecho("Styles", "    " .. styleStr .. "\n\n")
		end
	else
		-- Show all categories
		for catName, catStyles in pairs(ui.theme) do
			ui.devDisplay:cecho(
				"Styles",
				string.format("<gold>%s<reset> (%d styles)\n", catName, table.size(catStyles))
			)
		end
		ui.devDisplay:cecho("Styles", "\nUse 'ui dev styles <category>' to see specific styles\n")
	end

	ui.devDisplay:switchTab("Styles")
end

-- Error tracking
ui.dev.errors = {}
ui.dev.maxErrors = 50

function ui.dev.logError(source, error)
	table.insert(ui.dev.errors, 1, {
		time = os.date("%H:%M:%S"),
		source = source,
		error = error,
		traceback = debug.traceback(),
	})

	while #ui.dev.errors > ui.dev.maxErrors do
		table.remove(ui.dev.errors)
	end

	if ui.dev.enabled and ui.devDisplay then
		ui.dev.updateErrorLog()
	end
end

function ui.dev.updateErrorLog()
	if not ui.devDisplay then
		return
	end

	ui.devDisplay:clear("Errors")
	ui.devDisplay:cecho("Errors", ui.createHeader("Error Log", "Last " .. #ui.dev.errors .. " errors", 600) .. "\n\n")

	for i, err in ipairs(ui.dev.errors) do
		if i > 10 then
			break
		end

		ui.devDisplay:cecho(
			"Errors",
			string.format("<gray>%s<reset> <red>[%s]<reset>\n%s\n\n", err.time, err.source, err.error)
		)
	end
end

-- Help documentation
function ui.dev.updateHelp()
	if not ui.devDisplay then
		return
	end

	ui.devDisplay:clear("Help")
	ui.devDisplay:cecho("Help", ui.createHeader("Developer Tools Help", "", 600) .. "\n\n")

	local help = {
		{ "ui dev enable", "Enable developer mode" },
		{ "ui dev disable", "Disable developer mode" },
		{ "ui dev inspect <element>", "Inspect a UI element (e.g., 'ui dev inspect charDisplay')" },
		{ "ui dev gmcp start [filter]", "Start GMCP event monitoring" },
		{ "ui dev gmcp stop", "Stop GMCP event monitoring" },
		{ "ui dev perf start", "Start performance monitoring" },
		{ "ui dev perf stop", "Stop performance monitoring" },
		{ "ui dev perf show", "Show performance statistics" },
		{ "ui dev styles [category]", "Browse available styles" },
		{ "ui dev test <display>", "Test a display with mock data" },
		{ "ui dev reload <component>", "Reload a specific component" },
		{ "ui dev export", "Export current layout and settings" },
		{ "ui dev validate", "Check for common issues" },
		{ "ui dev overlay", "Toggle layout overlay" },
	}

	for _, cmd in ipairs(help) do
		ui.devDisplay:cecho("Help", string.format("  <yellow>%-30s<reset> %s\n", cmd[1], cmd[2]))
	end

	ui.devDisplay:switchTab("Help")
end

-- Mock data for testing displays
ui.dev.mockData = {
	vitals = {
		hp = 1000,
		maxhp = 1500,
		sp = 800,
		maxsp = 1000,
		xp = 50000,
		xpmax = 100000,
	},
	status = {
		level = 50,
		class = "Warrior",
		race = "Human",
	},
	room = {
		name = "Test Room",
		desc = "This is a test room for development purposes.",
		exits = { n = 1, s = 1, e = 1, w = 1 },
	},
	enemies = {
		{ name = "Test Enemy", hp = 500, maxhp = 1000, level = 45 },
	},
}

-- Test display with mock data
function ui.dev.testDisplay(displayName)
	if not ui[displayName] then
		ui.displayUIMessage("Display not found: " .. displayName)
		return
	end

	-- Temporarily set mock GMCP data
	local oldGmcp = gmcp
	gmcp = {
		Char = {
			Vitals = ui.dev.mockData.vitals,
			Status = ui.dev.mockData.status,
			Enemies = ui.dev.mockData.enemies,
		},
		Room = {
			Info = ui.dev.mockData.room,
		},
	}

	-- Update the display
	local updateFunc = "update" .. displayName:sub(1, 1):upper() .. displayName:sub(2)
	if ui[updateFunc] then
		ui[updateFunc]()
		ui.displayUIMessage("Tested " .. displayName .. " with mock data")
	else
		ui.displayUIMessage("No update function found for " .. displayName)
	end

	-- Restore GMCP
	gmcp = oldGmcp
end

-- Layout overlay
ui.dev.overlayEnabled = false

function ui.dev.toggleOverlay()
	ui.dev.overlayEnabled = not ui.dev.overlayEnabled

	if ui.dev.overlayEnabled then
		ui.dev.createOverlay()
	else
		ui.dev.removeOverlay()
	end

	ui.displayUIMessage("Layout overlay " .. (ui.dev.overlayEnabled and "enabled" or "disabled"))
end

function ui.dev.createOverlay()
	-- Create transparent overlays for each container
	ui.dev.overlays = {}

	for name, container in pairs(ui.settings.containers) do
		if ui[name] then
			local overlay = Geyser.Label:new({
				name = "ui.dev.overlay." .. name,
				x = ui[name]:get_x(),
				y = ui[name]:get_y(),
				width = ui[name]:get_width(),
				height = ui[name]:get_height(),
			})

			overlay:setStyleSheet([[
                background-color: rgba(255, 0, 0, 20%);
                border: 2px solid red;
            ]])

			overlay:echo("<center><b>" .. name .. "</b></center>")
			overlay:setClickCallback(function()
				ui.dev.inspect(name)
			end)

			ui.dev.overlays[name] = overlay
		end
	end
end

function ui.dev.removeOverlay()
	if ui.dev.overlays then
		for _, overlay in pairs(ui.dev.overlays) do
			overlay:hide()
			overlay = nil
		end
		ui.dev.overlays = nil
	end
end

-- Validate UI configuration
function ui.dev.validate()
	local issues = {}

	-- Check for missing containers
	for name, display in pairs(ui.settings.displays) do
		if not ui.settings.containers[display.dest] then
			table.insert(issues, "Display '" .. name .. "' references non-existent container '" .. display.dest .. "'")
		end
	end

	-- Check for duplicate positions
	local positions = {}
	for name, container in pairs(ui.settings.containers) do
		local key = container.dest .. ":" .. (container.x or 0) .. "," .. (container.y or 0)
		if positions[key] then
			table.insert(issues, "Container position conflict: '" .. name .. "' and '" .. positions[key] .. "'")
		end
		positions[key] = name
	end

	-- Check gauge positions
	local gaugePositions = {}
	for category, gauges in pairs(ui.gaugeManager.configs) do
		for gaugeName, config in pairs(gauges) do
			if config.position then
				local key = config.position.x .. "," .. config.position.y
				if gaugePositions[key] then
					table.insert(
						issues,
						"Gauge position conflict: '" .. config.name .. "' and '" .. gaugePositions[key] .. "'"
					)
				end
				gaugePositions[key] = config.name
			end
		end
	end

	-- Check for required functions
	local requiredFuncs = { "createContainers", "updateDisplays", "profileLoaded", "connected" }
	for _, func in ipairs(requiredFuncs) do
		if not ui[func] then
			table.insert(issues, "Missing required function: ui." .. func)
		end
	end

	-- Display results
	if #issues == 0 then
		ui.displayUIMessage("Validation passed! No issues found.")
	else
		ui.displayUIMessage("Validation found " .. #issues .. " issues:")
		for i, issue in ipairs(issues) do
			cecho("\n  <red>" .. i .. ".<reset> " .. issue)
		end
	end

	return issues
end

-- Export layout and settings
function ui.dev.export()
	local exportData = {
		version = ui.version,
		timestamp = os.date(),
		settings = ui.settings,
		containerPositions = {},
		displaySettings = {},
	}

	-- Get current container positions
	for name, _ in pairs(ui.settings.containers) do
		if ui[name] then
			exportData.containerPositions[name] = {
				x = ui[name]:get_x(),
				y = ui[name]:get_y(),
				width = ui[name]:get_width(),
				height = ui[name]:get_height(),
			}
		end
	end

	-- Save to file
	local filename = getMudletHomeDir() .. "/GoMudUI_export_" .. os.date("%Y%m%d_%H%M%S") .. ".lua"
	table.save(filename, exportData)

	ui.displayUIMessage("Layout exported to: " .. filename)
	return filename
end

-- Wrap update functions with performance tracking
function ui.dev.wrapUpdateFunctions()
	local updateFuncs = {
		"updateCharDisplay",
		"updateEQDisplay",
		"updateInvDisplay",
		"updateRoomDisplay",
		"updateChannelDisplay",
		"updateWhoDisplay",
		"updateAffectsDisplay",
		"updateGroupDisplay",
		"updateCombatDisplay",
		"updatePlayerGauges",
		"updateEnemyGauge",
		"updatePromptDisplay",
	}

	for _, funcName in ipairs(updateFuncs) do
		if ui[funcName] then
			local originalFunc = ui[funcName]
			ui[funcName] = function(...)
				return ui.dev.trackUpdate(funcName, function()
					return originalFunc(...)
				end)
			end
		end
	end
end

-- Initialize developer tools
function ui.dev.init()
	-- Wrap error-prone functions
	local oldError = error
	_G.error = function(msg, level)
		ui.dev.logError("error", msg)
		oldError(msg, level)
	end

	ui.displayUIMessage("Developer tools initialized. Use 'ui dev enable' to activate.")
end
