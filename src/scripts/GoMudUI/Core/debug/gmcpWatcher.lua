-- GMCP Watcher
-- This script periodically checks GMCP state to detect when it gets cleared

ui = ui or {}
ui.debug = ui.debug or {}

-- State tracking
ui.debug.gmcpWatcher = ui.debug.gmcpWatcher or {
    enabled = false,
    lastState = nil,
    timer = nil
}

function ui.debug.startGmcpWatcher(interval)
    interval = interval or 2 -- Check every 2 seconds by default
    
    ui.debug.gmcpWatcher.enabled = true
    ui.displayUIMessage("<yellow>Starting GMCP watcher (checking every " .. interval .. " seconds)<reset>")
    
    -- Kill existing timer if any
    if ui.debug.gmcpWatcher.timer then
        killTimer(ui.debug.gmcpWatcher.timer)
    end
    
    -- Create periodic check
    ui.debug.gmcpWatcher.timer = tempTimer(interval, function()
        ui.debug.checkGmcpState()
        if ui.debug.gmcpWatcher.enabled then
            ui.debug.gmcpWatcher.timer = tempTimer(interval, ui.debug.checkGmcpState)
        end
    end)
    
    -- Do initial check
    ui.debug.checkGmcpState()
end

function ui.debug.stopGmcpWatcher()
    ui.debug.gmcpWatcher.enabled = false
    if ui.debug.gmcpWatcher.timer then
        killTimer(ui.debug.gmcpWatcher.timer)
        ui.debug.gmcpWatcher.timer = nil
    end
    ui.displayUIMessage("<yellow>GMCP watcher stopped<reset>")
end

function ui.debug.checkGmcpState()
    local currentState = "unknown"
    local hasData = false
    
    if not gmcp then
        currentState = "nil"
    elseif type(gmcp) ~= "table" then
        currentState = "not-table"
    elseif not next(gmcp) then
        currentState = "empty"
    else
        currentState = "has-data"
        hasData = true
    end
    
    -- Check if state changed
    if ui.debug.gmcpWatcher.lastState and ui.debug.gmcpWatcher.lastState ~= currentState then
        -- State changed - this is important!
        local timestamp = os.date("%H:%M:%S")
        ui.displayUIMessage(string.format(
            "<red>GMCP STATE CHANGED at %s: %s -> %s<reset>",
            timestamp,
            ui.debug.gmcpWatcher.lastState,
            currentState
        ))
        
        -- If GMCP was cleared, try to get a stack trace
        if ui.debug.gmcpWatcher.lastState == "has-data" and not hasData then
            ui.displayUIMessage("<red>GMCP DATA WAS CLEARED!<reset>")
            -- Log current call stack if possible
            if debug and debug.traceback then
                local trace = debug.traceback("GMCP cleared here", 2)
                echo("\n" .. trace .. "\n")
            end
        end
        
        -- Do a detailed check
        ui.debugGMCP("State change detected")
    end
    
    ui.debug.gmcpWatcher.lastState = currentState
end

-- Add commands to control the watcher
function ui.debug.handleWatcherCommand(cmd)
    if cmd == "start" then
        ui.debug.startGmcpWatcher()
    elseif cmd == "stop" then
        ui.debug.stopGmcpWatcher()
    elseif cmd == "status" then
        if ui.debug.gmcpWatcher.enabled then
            ui.displayUIMessage("<green>GMCP watcher is running<reset>")
            ui.displayUIMessage("Current state: " .. (ui.debug.gmcpWatcher.lastState or "unknown"))
        else
            ui.displayUIMessage("<red>GMCP watcher is not running<reset>")
        end
    else
        ui.displayUIMessage("Usage: ui dev gmcpwatch start|stop|status")
    end
end

-- Auto-start the watcher for debugging
ui.debug.startGmcpWatcher()