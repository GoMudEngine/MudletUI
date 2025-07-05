# Enemy Gauge Tests

This directory contains test scripts to verify that the enemy gauge properly clears when combat ends.

## Test Files

### 1. `test_enemy_gauge_combat_end.lua`
A comprehensive test suite that simulates various combat scenarios:
- Combat with target
- Combat ending (in_combat = false)
- Target becoming "None" or empty
- No GMCP data scenarios

**Usage:**
```lua
-- Run the full test suite
runEnemyGaugeTests()

-- Check current enemy gauge state
checkEnemyGauge()

-- Simulate specific scenarios
simulateCombat("start")   -- Start combat
simulateCombat("end")     -- End combat
simulateCombat("notarget") -- In combat with no target
simulateCombat("clear")   -- Clear all combat data
```

### 2. `quick_enemy_gauge_test.lua`
A simple, visual test that you can watch in real-time:
- Shows combat starting with a target
- Demonstrates gauge clearing when combat ends
- Verifies gauge works when combat resumes

**Usage:**
```lua
testEnemyGaugeClear()
```

### 3. `gmcp_combat_monitor.lua`
A real-time monitor for debugging GMCP combat status events:
- Logs all combat status changes
- Shows what the enemy gauge should display
- Helps identify timing or data issues

**Usage:**
```lua
startCombatMonitor()  -- Start monitoring
stopCombatMonitor()   -- Stop monitoring
checkCombatStatus()   -- Check current status once
```

## How to Run Tests

1. **In Mudlet:**
   - Open the Scripts window
   - Create a new script
   - Copy the content of any test file
   - Save and run the commands shown above

2. **As an Alias:**
   - Create a new alias with pattern: `^test enemy gauge$`
   - Set the script to: `dofile("/Users/jens/mud/MudletUI/tests/quick_enemy_gauge_test.lua")`
   - Type "test enemy gauge" to load the test

3. **From Command Line:**
   ```lua
   lua dofile("/Users/jens/mud/MudletUI/tests/test_enemy_gauge_combat_end.lua")
   lua runEnemyGaugeTests()
   ```

## Expected Behavior

The enemy gauge should:
1. Display target name and HP when `in_combat = true` and a valid target exists
2. Show "No Target" when:
   - `in_combat = false` (regardless of target value)
   - `target = "None"` or empty string
   - No GMCP CombatStatus data exists

## Debugging Tips

If the enemy gauge isn't clearing properly:
1. Run `startCombatMonitor()` to see actual GMCP data
2. Check if the `gmcp.Char.CombatStatus` event is firing
3. Verify `ui.updateEnemyGauge()` is registered for the event
4. Look for any errors in the Mudlet error console

## Code References

The enemy gauge behavior is controlled by:
- `/src/scripts/GoMudUI/Core/infrastructure/gaugeManager.lua` - Main gauge logic
- `/src/scripts/GoMudUI/Components/combat/enemyGauge.lua` - Enemy gauge wrapper
- `/src/scripts/GoMudUI/Core/init/uiSettings.lua` - Event registration

The key function is `ui.gaugeManager.updateEnemyGauge()` which checks:
```lua
if not status.in_combat or not status.target or status.target == "None" or status.target == "" then
    -- Clear the gauge to "No Target"
end
```