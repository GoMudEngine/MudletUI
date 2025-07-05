-- GMCP Monitor
-- This script monitors GMCP state continuously to detect when it gets cleared

ui = ui or {}
ui.gmcpMonitor = ui.gmcpMonitor or {}

-- Start monitoring GMCP
function ui.gmcpMonitor.start()
	if ui.gmcpMonitor.timer then
		killTimer(ui.gmcpMonitor.timer)
	end
	
	ui.gmcpMonitor.lastState = "unknown"
	ui.gmcpMonitor.checkCount = 0
	
	-- Check GMCP state every 100ms
	ui.gmcpMonitor.timer = tempTimer(0.1, function()
		ui.gmcpMonitor.check()
		ui.gmcpMonitor.start() -- Reschedule
	end)
end

-- Check GMCP state
function ui.gmcpMonitor.check()
	ui.gmcpMonitor.checkCount = ui.gmcpMonitor.checkCount + 1
	
	local currentState
	if not gmcp then
		currentState = "nil"
	elseif type(gmcp) ~= "table" then
		currentState = "not-table"
	elseif not next(gmcp) then
		currentState = "empty"
	else
		local keyCount = 0
		for _ in pairs(gmcp) do
			keyCount = keyCount + 1
		end
		currentState = "has-" .. keyCount .. "-keys"
	end
	
	-- Only log when state changes
	if currentState ~= ui.gmcpMonitor.lastState then
		local timestamp = os.date("%H:%M:%S.") .. string.format("%03d", math.floor((os.clock() % 1) * 1000))
		ui.displayUIMessage(string.format("<yellow>[%s] GMCP STATE CHANGED: %s -> %s<reset>", 
			timestamp, ui.gmcpMonitor.lastState, currentState))
		
		-- Try to capture a stack trace
		local trace = debug.traceback("GMCP state change detected", 2)
		if ui.dev and ui.dev.enabled then
			display(trace)
		end
		
		ui.gmcpMonitor.lastState = currentState
	end
end

-- Stop monitoring
function ui.gmcpMonitor.stop()
	if ui.gmcpMonitor.timer then
		killTimer(ui.gmcpMonitor.timer)
		ui.gmcpMonitor.timer = nil
	end
	ui.displayUIMessage("GMCP monitoring stopped")
end

-- Auto-start monitoring only in development
if ui.muddlerCI and ui.muddlerCI.isDevelopment then
	ui.gmcpMonitor.start()
	ui.displayUIMessage("<cyan>GMCP Monitor started - watching for state changes<reset>")
else
	ui.displayUIMessage("<gray>GMCP Monitor available - use ui.gmcpMonitor.start() to enable<reset>")
end