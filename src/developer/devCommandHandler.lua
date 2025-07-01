-- Developer Command Handler
-- Handles all ui dev commands

function ui.handleDevCommand(matches)
	-- matches[3] contains everything after "ui dev"
	local restOfCommand = matches[3] or ""
	local subCommand, args

	-- Parse the command manually since split might not exist
	local spacePos = restOfCommand:find(" ")
	if spacePos then
		subCommand = restOfCommand:sub(1, spacePos - 1)
		args = restOfCommand:sub(spacePos + 1)
	else
		subCommand = restOfCommand
		args = ""
	end

	if not subCommand or subCommand == "" then
		ui.displayUIMessage("Use 'ui dev help' for available developer commands")
		return
	end

	-- Handle developer commands
	if subCommand == "enable" then
		ui.dev.enable()
	elseif subCommand == "disable" then
		ui.dev.disable()
	elseif subCommand == "help" then
		if ui.dev.enabled then
			ui.dev.updateHelp()
			if ui.devDisplay then
				ui.devDisplay:show()
				ui.devDisplay:switchTab("Help")
			end
		else
			-- Show basic help even when dev mode is disabled
			cecho([[

<gold>Developer Tools Commands:<reset>

  <yellow>ui dev enable<reset>              Enable developer mode
  <yellow>ui dev disable<reset>             Disable developer mode
  
When developer mode is enabled:
  <yellow>ui dev inspect <element><reset>   Inspect a UI element
  <yellow>ui dev gmcp start [filter]<reset> Start GMCP event monitoring
  <yellow>ui dev gmcp stop<reset>           Stop GMCP event monitoring
  <yellow>ui dev perf start<reset>          Start performance monitoring
  <yellow>ui dev perf stop<reset>           Stop performance monitoring
  <yellow>ui dev perf show<reset>           Show performance statistics
  <yellow>ui dev styles [category]<reset>   Browse available styles
  <yellow>ui dev test <display><reset>      Test display with mock data
  <yellow>ui dev overlay<reset>             Toggle layout overlay
  <yellow>ui dev validate<reset>            Check for common issues
  <yellow>ui dev export<reset>              Export layout and settings

]])
		end
	elseif subCommand == "inspect" then
		if not ui.dev.enabled then
			ui.displayUIMessage("Developer mode must be enabled first. Use 'ui dev enable'")
			return
		end
		if not args then
			ui.displayUIMessage("Usage: ui dev inspect <element>")
			ui.displayUIMessage("Example: ui dev inspect charDisplay")
			return
		end
		ui.dev.inspect(args)
	elseif subCommand == "gmcp" then
		if not ui.dev.enabled then
			ui.displayUIMessage("Developer mode must be enabled first. Use 'ui dev enable'")
			return
		end

		local gmcpCmd = args and args:match("^(%w+)") or ""
		local gmcpArgs = args and args:match("^%w+%s+(.+)")

		if gmcpCmd == "start" then
			ui.dev.startGmcpMonitor(gmcpArgs)
			if ui.devDisplay then
				ui.devDisplay:show()
				ui.devDisplay:switchTab("GMCP Monitor")
			end
		elseif gmcpCmd == "stop" then
			ui.dev.stopGmcpMonitor()
		else
			ui.displayUIMessage("Usage: ui dev gmcp start|stop [filter]")
		end
	elseif subCommand == "perf" then
		if not ui.dev.enabled then
			ui.displayUIMessage("Developer mode must be enabled first. Use 'ui dev enable'")
			return
		end

		local perfCmd = args
		if perfCmd == "start" then
			ui.dev.performance.enabled = true
			ui.dev.wrapUpdateFunctions()
			ui.displayUIMessage("Performance monitoring started")
		elseif perfCmd == "stop" then
			ui.dev.performance.enabled = false
			ui.displayUIMessage("Performance monitoring stopped")
		elseif perfCmd == "show" then
			ui.dev.showPerformance()
			if ui.devDisplay then
				ui.devDisplay:show()
			end
		else
			ui.displayUIMessage("Usage: ui dev perf start|stop|show")
		end
	elseif subCommand == "styles" then
		if not ui.dev.enabled then
			ui.displayUIMessage("Developer mode must be enabled first. Use 'ui dev enable'")
			return
		end
		ui.dev.showStyles(args)
		if ui.devDisplay then
			ui.devDisplay:show()
		end
	elseif subCommand == "test" then
		if not ui.dev.enabled then
			ui.displayUIMessage("Developer mode must be enabled first. Use 'ui dev enable'")
			return
		end
		if not args then
			ui.displayUIMessage("Usage: ui dev test <display>")
			ui.displayUIMessage("Example: ui dev test charDisplay")
			return
		end
		ui.dev.testDisplay(args)
	elseif subCommand == "overlay" then
		if not ui.dev.enabled then
			ui.displayUIMessage("Developer mode must be enabled first. Use 'ui dev enable'")
			return
		end
		ui.dev.toggleOverlay()
	elseif subCommand == "validate" then
		ui.dev.validate()
	elseif subCommand == "export" then
		ui.dev.export()
	elseif subCommand == "reload" then
		if not args then
			ui.displayUIMessage("Usage: ui dev reload <component>")
			return
		end
		-- Reload specific component
		if args == "styles" then
			ui.applyTheme()
			ui.displayUIMessage("Styles reloaded")
		elseif args == "gauges" then
			ui.gaugeManager.refreshAll()
			ui.displayUIMessage("Gauges refreshed")
		elseif args == "displays" then
			ui.updateDisplays()
			ui.displayUIMessage("All displays updated")
		else
			ui.displayUIMessage("Unknown component: " .. args)
		end
	else
		ui.displayUIMessage("Unknown developer command: " .. subCommand)
		ui.displayUIMessage("Use 'ui dev help' for available commands")
	end
end
