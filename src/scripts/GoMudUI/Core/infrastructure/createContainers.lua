function ui.createContainers(arg)
	-- Debug: Check GMCP at start of createContainers
	ui.debugGMCP("createContainers START")
	
	-- Guard against being called too early
	if not ui then
		ui = {}
	end
	
	-- Ensure settings are loaded
	if not ui.settings then
		ui.displayUIMessage("Settings not loaded yet, creating defaults...")
		if ui.createSettings then
			ui.createSettings()
		else
			-- If createSettings doesn't exist yet, we're being called too early
			ui.displayUIMessage("ERROR: UI system not ready, deferring container creation")
			return
		end
	end
	
	-- Initialize theme if not already done
	if not ui.theme and ui.initTheme then
		ui.initTheme()
	end
	
	-- Do some caltulations on font sizes to make sure everything fits into the console we create
	-- By calculating the pixel width of the font, we are able to make sure we size the consoles and windows correctly
	ui.consoleFontWidth, ui.consoleFontHeight = calcFontSize(ui.settings.consoleFontSize, ui.settings.consoleFont)

	-- If someone sets a different font/fontsize in the main window, lets make sure we have that defined as well
	ui.mainFontWidth, ui.mainFontHeight = calcFontSize(getFontSize("main"), getFont(main))

	-- Lets calculate the gauge font sizes as well
	ui.gaugeFontWidth, ui.gaugeFontHeight = calcFontSize(ui.settings.gaugeFontSize, ui.settings.consoleFont)

	-- Lets calculate the prompt font sizes as well
	ui.promptFontWidth, ui.promptFontHeight = calcFontSize(ui.settings.promptFontSize, ui.settings.consoleFont)

	-------------[ If a full reset is required ]-------------
	local arg = arg
	local containerAutoload = true

	if arg == "reset" then
		for k, v in pairs(ui.settings.containers) do
			if ui[k] then
				ui[k]:deleteSaveFile()
				ui[k] = nil
			end
			ui.top = nil
			ui.left = nil
			ui.right = nil
			ui.bottom = nil
			containerAutoload = false
		end
		for k, v in pairs(ui.settings.displays) do
			ui[k] = nil
			containerAutoload = false
		end
	end

	-------------[ Start by building the borders ]-------------

	-- Check if Adjustable.Container is available
	if not Adjustable or not Adjustable.Container then
		ui.displayUIMessage("ERROR: Adjustable containers not available yet")
		return
	end

	-- Build top border with safe style retrieval
	local topParams = {
		name = "ui.top",
		y = 0,
		height = "4c",
		padding = 4,
		attachedMargin = 0,
		autoLoad = containerAutoload,
	}
	
	-- Only add style if we have one
	if ui.getStyle then
		local topStyle = ui.getStyle("containers", "top")
		if topStyle and topStyle ~= "" then
			topParams.adjLabelstyle = topStyle
		end
	end
	
	ui.top = ui.top or Adjustable.Container:new(topParams)

	-- Build bottom border
	local bottomParams = {
		name = "ui.bottom",
		height = 105,
		y = -105,
		padding = 4,
		attachedMargin = 0,
		autoLoad = containerAutoload,
	}
	
	if ui.getStyle then
		local bottomStyle = ui.getStyle("containers", "bottom")
		if bottomStyle and bottomStyle ~= "" then
			bottomParams.adjLabelstyle = bottomStyle
		end
	end
	
	ui.bottom = ui.bottom or Adjustable.Container:new(bottomParams)

	-- Build right border
	local rightParams = {
		name = "ui.right",
		y = "0%",
		x = "-30%",
		height = "100%",
		width = "30%",
		padding = 4,
		attachedMargin = 0,
		autoLoad = containerAutoload,
	}
	
	if ui.getStyle then
		local rightStyle = ui.getStyle("containers", "right")
		if rightStyle and rightStyle ~= "" then
			rightParams.adjLabelstyle = rightStyle
		end
	end
	
	ui.right = ui.right or Adjustable.Container:new(rightParams)

	-- Build left border
	local leftParams = {
		name = "ui.left",
		x = "0%",
		y = "0%",
		height = "100%",
		width = ui.consoleFontWidth * 46,
		padding = 4,
		attachedMargin = 10,
		autoLoad = containerAutoload,
	}
	
	if ui.getStyle then
		local leftStyle = ui.getStyle("containers", "left")
		if leftStyle and leftStyle ~= "" then
			leftParams.adjLabelstyle = leftStyle
		end
	end
	
	ui.left = ui.left or Adjustable.Container:new(leftParams)

	ui.top:attachToBorder("top")
	ui.bottom:attachToBorder("bottom")
	ui.left:attachToBorder("left")
	ui.right:attachToBorder("right")

	ui.top:connectToBorder("left")
	ui.top:connectToBorder("right")
	ui.bottom:connectToBorder("left")
	ui.bottom:connectToBorder("right")

	ui.top:lockContainer("border")
	ui.left:lockContainer("border")
	ui.right:lockContainer("border")
	ui.bottom:lockContainer("border")
	
	-- Show the border containers
	ui.top:show()
	ui.left:show()
	ui.right:show()
	ui.bottom:show()
	
	-- Set borders to make room for the containers (with a small delay for initialization)
	tempTimer(0.1, function()
		local topHeight = ui.top:get_height()
		local bottomHeight = ui.bottom:get_height()
		local leftWidth = ui.left:get_width()
		local rightWidth = ui.right:get_width()
		
		setBorderTop(topHeight)
		setBorderBottom(bottomHeight)
		setBorderLeft(leftWidth)
		setBorderRight(rightWidth)
		
		-- Debug output
		ui.displayUIMessage(string.format("Borders set - Top: %d, Bottom: %d, Left: %d, Right: %d", 
			topHeight, bottomHeight, leftWidth, rightWidth))
	end)

	-- Knowing the window size, lets us calculate how mush space we can use for everything else and still display the mud output
	ui.mainWindowWidth = select(1, getMainWindowSize()) - ui.left:get_width() - ui.right:get_width()

	-------------[ Build the adjustable containers ]-------------
	for k, v in pairs(ui.settings.containers) do
		local consoleHeight = ""
		local consoleY = ""
		local w, h
		if v.fs and v.fs ~= "" then
			w, h = calcFontSize(v.fs, ui.settings.consoleFont)
		else
			h = ui.consoleFontHeight
		end

		if assert(type(v.height)) == "number" then
			consoleHeight = h * v.height
		else
			consoleHeight = v.height
		end
		if assert(type(v.y)) == "number" then
			consoleY = h * v.y
		else
			consoleY = v.y
		end

		local containerName = "ui." .. k

		-- Build container parameters with safety checks
		local containerParams = {
			name = containerName,
			titleText = k,
			x = v.x or 0,
			y = consoleY,
			padding = 5,
			attachedMargin = 0,
			width = v.width or "100%",
			autoWrap = v.wrap or false,
			height = consoleHeight,
			fontSize = v.fs or (ui.settings and ui.settings.consoleFontSize) or 11,
			autoLoad = containerAutoload,
		}
		
		-- Get style safely
		local moveableStyle = ui.getStyle("containers", "moveable")
		if v.customCSS then
			containerParams.adjLabelstyle = v.customCSS
		elseif moveableStyle and moveableStyle ~= "" then
			containerParams.adjLabelstyle = moveableStyle
		end
		
		ui[k] = ui[k] or Adjustable.Container:new(containerParams, ui[v.dest])
		
		-- Debug output
		if k == "container5" or k == "container6" or k == "container10" then
			ui.displayUIMessage(string.format("Creating %s in %s (parent exists: %s)", k, v.dest or "nil", tostring(ui[v.dest] ~= nil)))
			if not ui[v.dest] then
				ui.displayUIMessage(string.format("ERROR: Parent container %s does not exist for %s!", v.dest, k))
			end
		end

		ui[k]:newCustomItem("Move to left side", function(self)
			ui.putContainer("left", k)
		end)

		ui[k]:newCustomItem("Move to right side", function(self)
			ui.putContainer("right", k)
		end)

		ui[k]:newCustomItem("Move to bottom", function(self)
			ui.putContainer("bottom", k)
		end)

		ui[k]:newCustomItem("Move to top", function(self)
			ui.putContainer("top", k)
		end)

		ui[k]:newCustomItem("Pop out", function(self)
			ui.popOutContainer(k)
		end)

		ui[k]:lockContainer("border")
	end

	-------------[ Build the EMCO and Miniconsole objects ]-------------

	for k, v in pairs(ui.settings.displays) do
		-- Debug output for prompt display
		if k == "promptDisplay" then
			ui.displayUIMessage(string.format("Creating promptDisplay in %s (container exists: %s)", v.dest, tostring(ui[v.dest] ~= nil)))
		end
		
		-- Special case: gaugeDisplay is just a reference to its container
		if k == "gaugeDisplay" then
			ui[k] = ui[v.dest]
			ui.displayUIMessage(string.format("gaugeDisplay set to %s (which is %s)", v.dest, tostring(ui[k])))
		else
			local containerName = "ui." .. k
			local console = v.tabs

			if v.emco and not v.mapper then
			-- Build EMCO parameters with safety checks
			local emcoParams = {
				name = containerName,
				x = 0,
				y = 2,
				width = "100%",
				height = "100%",
				tabFontSize = (ui.settings and ui.settings.tabFontSize) or 12,
				tabHeight = (ui.settings and ui.settings.tabHeight) or 20,
				gap = (ui.settings and ui.settings.tabGap) or 2,
				fontSize = (ui.settings and ui.settings.consoleFontSize) or 11,
				font = (ui.settings and ui.settings.consoleFont) or "Bitstream Vera Sans Mono",
				tabFont = (ui.settings and ui.settings.consoleFont) or "Bitstream Vera Sans Mono",
				autoWrap = v.wrap or false,
				tabBoxColor = (ui.settings and ui.settings.tabBarColor) or "<15,15,15>",
				consoleColor = (ui.settings and ui.settings.consoleBackgroundColor) or "<15,15,15>",
				activeTabFGColor = (ui.settings and ui.settings.activeTabFGColor) or "white",
				inactiveTabFGColor = (ui.settings and ui.settings.inactiveTabFGColor) or "white",
				consoles = console,
			}
			
			-- Get styles safely
			local activeStyle = ui.getStyle("tabs", "active")
			if activeStyle and activeStyle ~= "" then
				emcoParams.activeTabCSS = activeStyle
			end
			
			local inactiveStyle = ui.getStyle("tabs", "inactive") 
			if inactiveStyle and inactiveStyle ~= "" then
				emcoParams.inactiveTabCSS = inactiveStyle
			end
			
			ui[k] = EMCO:new(emcoParams, ui[v.dest])
			ui[k]:disableAllLogging()
		elseif v.mapper then
			-- Build mapper EMCO parameters with safety checks
			local mapperParams = {
				name = containerName,
				x = 0,
				y = 2,
				width = "100%",
				height = "100%",
				tabFontSize = (ui.settings and ui.settings.tabFontSize) or 12,
				tabHeight = (ui.settings and ui.settings.tabHeight) or 20,
				gap = (ui.settings and ui.settings.tabGap) or 2,
				fontSize = (ui.settings and ui.settings.consoleFontSize) or 11,
				font = (ui.settings and ui.settings.consoleFont) or "Bitstream Vera Sans Mono",
				tabFont = (ui.settings and ui.settings.consoleFont) or "Bitstream Vera Sans Mono",
				allTab = false,
				autoWrap = false,
				mapTab = true,
				mapTabName = v.mapTab,
				tabBoxColor = (ui.settings and ui.settings.consoleBackgroundColor) or "<15,15,15>",
				consoleContainerColor = (ui.settings and ui.settings.consoleBackgroundColor) or "<15,15,15>",
				consoleColor = (ui.settings and ui.settings.consoleBackgroundColor) or "<15,15,15>",
				activeTabFGColor = (ui.settings and ui.settings.activeTabFGColor) or "white",
				inactiveTabFGColor = (ui.settings and ui.settings.inactiveTabFGColor) or "white",
				consoles = console,
			}
			
			-- Get styles safely
			local activeStyle = ui.getStyle("tabs", "active")
			if activeStyle and activeStyle ~= "" then
				mapperParams.activeTabCSS = activeStyle
			end
			
			local inactiveStyle = ui.getStyle("tabs", "inactive")
			if inactiveStyle and inactiveStyle ~= "" then
				mapperParams.inactiveTabCSS = inactiveStyle
			end
			
			ui[k] = EMCO:new(mapperParams, ui[v.dest])
			ui[k]:disableAllLogging()

			-- Set a map zoom level that is comfortable for most people
			setMapZoom(10)

			-- Set the mapper background color the same as everything else
			setMapBackgroundColor(15, 15, 15)
		else
			-- Ensure all values are not nil
			local miniConsoleParams = {
				name = containerName,
				x = v.x or 0,
				y = 0,
				width = v.width or "100%",
				padding = 4,
				height = "100%",
				fontSize = ui.settings and ui.settings.promptFontSize or 12,
				font = ui.settings and ui.settings.consoleFont or "Bitstream Vera Sans Mono",
				autoWrap = false,
				color = ui.settings and ui.settings.consoleBackgroundColor or "black",
				autoLoad = containerAutoload,
			}
			
			-- Get style, ensuring it's not nil
			local style = ui.getStyle("containers", "noBorder")
			if style and style ~= "" then
				miniConsoleParams.adjLabelstyle = style
			end
			
			ui[k] = Geyser.MiniConsole:new(miniConsoleParams, ui[v.dest])
			end
		end
	end

	-- Initialize gauges using the gauge manager
	if ui.gaugeManager and ui.gaugeManager.initialize then
		ui.gaugeManager.initialize()
	else
		ui.displayUIMessage("Warning: Gauge manager not available yet")
	end
	
	-- Don't initialize here - wait for UICreated event
	
	if arg == "layout_update" then
		ui.updateDisplays({ type = "update" })
	else
		ui.updateDisplays()
	end

	if arg == "reset" then
		ui.displayUIMessage("UI layout set to default")
		raiseWindow("mapper")
	end
	if arg == "startup" then
		ui.displayUIMessage("UI containers created")
		ui.containersCreated = true
		
		-- Debug: Check GMCP after containers created
		ui.debugGMCP("createContainers COMPLETE")
		
		-- Restore saved tab states
		if ui.tabStateManager and ui.tabStateManager.restoreAllTabs then
			tempTimer(2, function()
				ui.tabStateManager.restoreAllTabs()
			end)
		end
		
		-- Raise events to signal UI is ready
		raiseEvent("UICreated")
		raiseEvent("ui.ready")
		raiseEvent("GoMudUI.initialized")
		raiseWindow("mapper")
	end
end
