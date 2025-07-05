-- Tab State Manager
-- Handles saving and restoring active tabs for all EMCO displays

ui = ui or {}
ui.tabStateManager = ui.tabStateManager or {}

-- Flag to prevent saving during initialization
ui.tabStateManager.initialized = false

-- Save the active tab when a tab change occurs
function ui.tabStateManager.saveTabChange(event, displayName, oldTab, newTab)
	-- Don't save during initialization
	if not ui.tabStateManager.initialized then
		return
	end
	
	-- Only process if we have a valid new tab and display name
	if not newTab or not displayName then
		return
	end
	
	-- Initialize settings if needed
	ui.settings = ui.settings or {}
	ui.settings.activeTabs = ui.settings.activeTabs or {}
	
	-- Save the active tab for this display
	ui.settings.activeTabs[displayName] = newTab
	
	-- Save settings to disk (this happens on exit too, but we save immediately for safety)
	if ui.packageName then
		table.save(getMudletHomeDir() .. "/" .. ui.packageName .. "/ui.settings.lua", ui.settings)
	end
	
	-- Debug message
	ui.displayUIMessage(string.format("<dim_grey>Tab saved: %s -> %s<reset>", displayName, newTab))
end

-- Restore all saved tabs after UI creation
function ui.tabStateManager.restoreAllTabs()
	-- Check if we have saved tab states
	if not ui.settings or not ui.settings.activeTabs then
		ui.displayUIMessage("No saved tab states to restore")
		return
	end
	
	ui.displayUIMessage("Restoring tab states...")
	local restoredCount = 0
	
	-- List of all tabbed displays
	local tabbedDisplays = {
		"ui.charDisplay",
		"ui.eqDisplay", 
		"ui.roomDisplay",
		"ui.channelDisplay",
		"ui.mapperDisplay",
		"ui.affectsDisplay",
		"ui.devDisplay"
	}
	
	-- Restore each display's active tab
	for _, displayName in ipairs(tabbedDisplays) do
		-- Get the actual display object (remove "ui." prefix to access the object)
		local objectName = displayName:gsub("^ui%.", "")
		local display = ui[objectName]
		local savedTab = ui.settings.activeTabs[displayName]
		
		if display and savedTab and type(display.switchTab) == "function" then
			
			-- EMCO stores tab names in display.consoles as an array
			local tabExists = false
			local availableTabs = {}
			
			-- Check display.consoles (array of tab names)
			if display.consoles then
				for i, tabName in ipairs(display.consoles) do
					availableTabs[tostring(tabName)] = true
					if tostring(tabName) == savedTab then
						tabExists = true
					end
				end
			end
			
			-- Also check display.tabs (table of tab objects keyed by name)
			if not tabExists and display.tabs then
				for tabName, _ in pairs(display.tabs) do
					availableTabs[tabName] = true
					if tabName == savedTab then
						tabExists = true
					end
				end
			end
			
			-- Switch to the saved tab if it exists
			if tabExists then
				display:switchTab(savedTab)
				restoredCount = restoredCount + 1
			end
		end
	end
	
	ui.displayUIMessage(string.format("Restored %d tab states", restoredCount))
	
	-- Mark as initialized so future tab changes will be saved
	ui.tabStateManager.initialized = true
end

-- Hook into the existing EMCO tab change handler
function ui.handleTabChange(event, displayName, oldTab, newTab)
	-- Always save tab changes (including mapperDisplay)
	ui.tabStateManager.saveTabChange(event, displayName, oldTab, newTab)
	
	-- Also call the original handler for mapperDisplay Settings tab
	if displayName == "ui.mapperDisplay" and newTab == "Settings" then
		ui.showSettings(event, displayName, oldTab, newTab)
	end
end

ui.displayUIMessage("Tab State Manager initialized")