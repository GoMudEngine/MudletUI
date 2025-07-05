--[[
Test Script: Enemy Gauge Combat End Behavior
Purpose: Verify that the enemy gauge properly clears when combat ends
Author: Test Script
Date: Created by Claude

This test simulates GMCP combat status changes to verify:
1. Enemy gauge shows target information during combat
2. Enemy gauge clears to "No Target" when combat ends (in_combat = false)
3. Enemy gauge clears when target becomes "None" or empty
]]

-- Test harness setup
local testResults = {}
local testsPassed = 0
local testsFailed = 0

-- Helper function to log test results
local function logTest(testName, passed, message)
    local status = passed and "PASS" or "FAIL"
    local result = string.format("[%s] %s: %s", status, testName, message or "")
    table.insert(testResults, result)
    
    if passed then
        testsPassed = testsPassed + 1
    else
        testsFailed = testsFailed + 1
    end
    
    print(result)
end

-- Helper function to simulate GMCP data
local function setGMCPData(data)
    gmcp = gmcp or {}
    gmcp.Char = gmcp.Char or {}
    gmcp.Char.CombatStatus = data
end

-- Helper function to trigger GMCP event
local function triggerCombatStatusEvent()
    raiseEvent("gmcp.Char.CombatStatus")
end

-- Helper function to get current enemy gauge text
local function getEnemyGaugeText()
    if ui and ui.enemyGauge then
        -- Try to get the text from the gauge
        -- Note: This might need adjustment based on how Mudlet exposes gauge text
        return ui.enemyGauge.text or "Unable to read gauge text"
    else
        return "Enemy gauge not found"
    end
end

-- Helper function to wait and process events
local function waitAndProcess(seconds)
    local endTime = os.time() + seconds
    while os.time() < endTime do
        -- Allow Mudlet to process events
        coroutine.yield()
    end
end

-- Main test function
function runEnemyGaugeTests()
    print("\n===== ENEMY GAUGE COMBAT END TEST SUITE =====\n")
    
    -- Ensure UI is initialized
    if not ui or not ui.gaugeManager then
        logTest("UI Initialization", false, "UI system not initialized")
        return
    end
    
    -- Test 1: Verify enemy gauge exists
    logTest("Enemy Gauge Exists", ui.enemyGauge ~= nil, "Checking if enemy gauge is created")
    
    -- Test 2: Set initial combat state with target
    print("\nTest 2: Simulating combat with target...")
    setGMCPData({
        in_combat = true,
        target = "a fierce goblin",
        target_hp_current = 80,
        target_hp_max = 100
    })
    triggerCombatStatusEvent()
    
    -- Give UI time to update
    tempTimer(0.1, function()
        local gaugeText = getEnemyGaugeText()
        logTest("Combat Target Display", 
                gaugeText and string.find(gaugeText, "fierce goblin") ~= nil,
                "Enemy gauge should show: 'a fierce goblin: 80/100'")
        
        -- Test 3: End combat by setting in_combat to false
        print("\nTest 3: Ending combat (in_combat = false)...")
        setGMCPData({
            in_combat = false,
            target = "a fierce goblin",  -- Target still exists but combat ended
            target_hp_current = 80,
            target_hp_max = 100
        })
        triggerCombatStatusEvent()
        
        tempTimer(0.1, function()
            gaugeText = getEnemyGaugeText()
            logTest("Combat End - in_combat false", 
                    gaugeText == "No Target",
                    "Enemy gauge should show 'No Target' when in_combat = false")
            
            -- Test 4: Start combat again
            print("\nTest 4: Resuming combat...")
            setGMCPData({
                in_combat = true,
                target = "an orc warrior",
                target_hp_current = 150,
                target_hp_max = 200
            })
            triggerCombatStatusEvent()
            
            tempTimer(0.1, function()
                gaugeText = getEnemyGaugeText()
                logTest("Resume Combat", 
                        gaugeText and string.find(gaugeText, "orc warrior") ~= nil,
                        "Enemy gauge should show new target")
                
                -- Test 5: Clear target by setting to "None"
                print("\nTest 5: Clearing target (target = 'None')...")
                setGMCPData({
                    in_combat = true,  -- Still in combat but no target
                    target = "None",
                    target_hp_current = 0,
                    target_hp_max = 0
                })
                triggerCombatStatusEvent()
                
                tempTimer(0.1, function()
                    gaugeText = getEnemyGaugeText()
                    logTest("Target None", 
                            gaugeText == "No Target",
                            "Enemy gauge should show 'No Target' when target = 'None'")
                    
                    -- Test 6: Empty target string
                    print("\nTest 6: Empty target string...")
                    setGMCPData({
                        in_combat = true,
                        target = "",
                        target_hp_current = 0,
                        target_hp_max = 0
                    })
                    triggerCombatStatusEvent()
                    
                    tempTimer(0.1, function()
                        gaugeText = getEnemyGaugeText()
                        logTest("Empty Target", 
                                gaugeText == "No Target",
                                "Enemy gauge should show 'No Target' when target is empty")
                        
                        -- Test 7: No GMCP data at all
                        print("\nTest 7: No GMCP data...")
                        gmcp.Char.CombatStatus = nil
                        triggerCombatStatusEvent()
                        
                        tempTimer(0.1, function()
                            gaugeText = getEnemyGaugeText()
                            logTest("No GMCP Data", 
                                    gaugeText == "No Target",
                                    "Enemy gauge should show 'No Target' when no GMCP data")
                            
                            -- Print summary
                            print("\n===== TEST SUMMARY =====")
                            print(string.format("Tests Passed: %d", testsPassed))
                            print(string.format("Tests Failed: %d", testsFailed))
                            print(string.format("Total Tests: %d", testsPassed + testsFailed))
                            print("\nDetailed Results:")
                            for _, result in ipairs(testResults) do
                                print(result)
                            end
                            print("\n===== END OF TESTS =====\n")
                        end)
                    end)
                end)
            end)
        end)
    end)
end

-- Function to manually check enemy gauge state
function checkEnemyGauge()
    print("\n=== CURRENT ENEMY GAUGE STATE ===")
    
    if not ui or not ui.enemyGauge then
        print("Enemy gauge not found!")
        return
    end
    
    print("Enemy gauge exists: Yes")
    
    if gmcp and gmcp.Char and gmcp.Char.CombatStatus then
        local status = gmcp.Char.CombatStatus
        print("\nCurrent GMCP CombatStatus:")
        print(string.format("  in_combat: %s", tostring(status.in_combat)))
        print(string.format("  target: %s", tostring(status.target)))
        print(string.format("  target_hp_current: %s", tostring(status.target_hp_current)))
        print(string.format("  target_hp_max: %s", tostring(status.target_hp_max)))
    else
        print("\nNo GMCP CombatStatus data available")
    end
    
    print(string.format("\nEnemy gauge text: %s", getEnemyGaugeText()))
    print("=================================\n")
end

-- Function to manually simulate combat scenarios
function simulateCombat(scenario)
    print("\n=== SIMULATING COMBAT SCENARIO: " .. (scenario or "custom") .. " ===")
    
    if scenario == "start" then
        -- Start combat with a target
        setGMCPData({
            in_combat = true,
            target = "a test monster",
            target_hp_current = 100,
            target_hp_max = 100
        })
        print("Started combat with 'a test monster'")
        
    elseif scenario == "end" then
        -- End combat (in_combat = false)
        setGMCPData({
            in_combat = false,
            target = "a test monster",
            target_hp_current = 50,
            target_hp_max = 100
        })
        print("Ended combat (in_combat = false)")
        
    elseif scenario == "notarget" then
        -- In combat but no target
        setGMCPData({
            in_combat = true,
            target = "None",
            target_hp_current = 0,
            target_hp_max = 0
        })
        print("In combat but no target")
        
    elseif scenario == "clear" then
        -- Clear all combat data
        gmcp.Char.CombatStatus = nil
        print("Cleared all combat data")
        
    else
        print("Unknown scenario. Use: start, end, notarget, or clear")
        return
    end
    
    triggerCombatStatusEvent()
    
    tempTimer(0.1, function()
        checkEnemyGauge()
    end)
end

-- Instructions for use
print([[
Enemy Gauge Combat End Test Script Loaded!

Available commands:
- runEnemyGaugeTests()     : Run the full test suite
- checkEnemyGauge()        : Check current enemy gauge state
- simulateCombat("start")  : Simulate starting combat
- simulateCombat("end")    : Simulate ending combat
- simulateCombat("notarget") : Simulate in combat with no target
- simulateCombat("clear")  : Clear all combat data

To test manually:
1. Start your game and connect
2. Run: checkEnemyGauge() to see current state
3. Enter combat in-game and run checkEnemyGauge() again
4. Exit combat and verify gauge shows "No Target"

To run automated tests:
- Execute: runEnemyGaugeTests()
]])