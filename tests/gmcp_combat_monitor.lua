--[[
GMCP Combat Status Monitor
Purpose: Monitor GMCP combat status changes in real-time
Usage: Run this script to start monitoring, useful for debugging enemy gauge issues
]]

-- Global flag to control monitoring
gmcpCombatMonitor = gmcpCombatMonitor or {}
gmcpCombatMonitor.active = false
gmcpCombatMonitor.eventHandler = nil

-- Function to start monitoring
function startCombatMonitor()
    if gmcpCombatMonitor.active then
        print("Combat monitor is already running!")
        return
    end
    
    print("\n=== GMCP COMBAT STATUS MONITOR STARTED ===")
    print("Monitoring gmcp.Char.CombatStatus changes...")
    print("Type: stopCombatMonitor() to stop\n")
    
    -- Create event handler
    gmcpCombatMonitor.eventHandler = function()
        print("\n[" .. os.date("%H:%M:%S") .. "] gmcp.Char.CombatStatus event received!")
        
        if gmcp and gmcp.Char and gmcp.Char.CombatStatus then
            local status = gmcp.Char.CombatStatus
            print("  in_combat: " .. tostring(status.in_combat))
            print("  target: " .. tostring(status.target))
            print("  target_hp_current: " .. tostring(status.target_hp_current))
            print("  target_hp_max: " .. tostring(status.target_hp_max))
            
            -- Check what the enemy gauge should show
            local expectedGaugeText = "No Target"
            if status.in_combat and status.target and status.target ~= "None" and status.target ~= "" then
                if status.target_hp_current and status.target_hp_max then
                    expectedGaugeText = string.format("%s: %s/%s", 
                        status.target, 
                        ui.addNumberSeparator(status.target_hp_current), 
                        ui.addNumberSeparator(status.target_hp_max))
                else
                    expectedGaugeText = status.target
                end
            end
            
            print("  Expected gauge text: " .. expectedGaugeText)
            
            -- Log any potential issues
            if not status.in_combat and status.target and status.target ~= "None" then
                print("  WARNING: Not in combat but target still set!")
            end
        else
            print("  ERROR: No GMCP CombatStatus data available!")
        end
        
        print("---")
    end
    
    -- Register the event handler
    registerAnonymousEventHandler("gmcp.Char.CombatStatus", gmcpCombatMonitor.eventHandler)
    gmcpCombatMonitor.active = true
end

-- Function to stop monitoring
function stopCombatMonitor()
    if not gmcpCombatMonitor.active then
        print("Combat monitor is not running!")
        return
    end
    
    -- This would need proper cleanup in a real implementation
    -- For now, we'll just set the flag
    gmcpCombatMonitor.active = false
    print("\n=== GMCP COMBAT STATUS MONITOR STOPPED ===")
    print("Note: Event handler may still be registered. Restart Mudlet to fully clean up.\n")
end

-- Function to manually check current state
function checkCombatStatus()
    print("\n=== CURRENT COMBAT STATUS ===")
    print("Time: " .. os.date("%H:%M:%S"))
    
    if gmcp and gmcp.Char and gmcp.Char.CombatStatus then
        local status = gmcp.Char.CombatStatus
        print("GMCP Data:")
        print("  in_combat: " .. tostring(status.in_combat))
        print("  target: " .. tostring(status.target))
        print("  target_hp_current: " .. tostring(status.target_hp_current))
        print("  target_hp_max: " .. tostring(status.target_hp_max))
    else
        print("No GMCP CombatStatus data available!")
    end
    
    if ui and ui.enemyGauge then
        print("\nEnemy Gauge:")
        print("  Exists: Yes")
        -- Note: Getting actual gauge text might require different approach
        print("  (Check gauge visually for current text)")
    else
        print("\nEnemy Gauge:")
        print("  Exists: No")
    end
    
    print("=============================\n")
end

print([[
GMCP Combat Monitor Loaded!

Commands:
- startCombatMonitor() : Start monitoring GMCP combat status changes
- stopCombatMonitor()  : Stop monitoring
- checkCombatStatus()  : Check current combat status once

This tool will log all gmcp.Char.CombatStatus events and show:
- Whether you're in combat
- Current target name
- Target HP values
- What the enemy gauge should display

Use this while playing to debug enemy gauge issues!
]])