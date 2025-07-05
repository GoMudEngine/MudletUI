--[[
Quick Enemy Gauge Test
Purpose: Simple test to verify enemy gauge clears when combat ends
Usage: Copy and paste this into Mudlet's script editor or run as an alias
]]

-- Quick test function
function testEnemyGaugeClear()
    print("\n=== TESTING ENEMY GAUGE CLEAR ON COMBAT END ===\n")
    
    -- Step 1: Simulate being in combat with a target
    print("Step 1: Simulating combat with target 'a goblin warrior'")
    gmcp = gmcp or {}
    gmcp.Char = gmcp.Char or {}
    gmcp.Char.CombatStatus = {
        in_combat = true,
        target = "a goblin warrior",
        target_hp_current = 75,
        target_hp_max = 100
    }
    
    -- Trigger the update
    raiseEvent("gmcp.Char.CombatStatus")
    
    -- Wait a moment for UI to update
    tempTimer(0.2, function()
        print("Enemy gauge should now show: 'a goblin warrior: 75/100'")
        print("Please verify the enemy gauge displays the target.\n")
        
        -- Step 2: Simulate combat ending
        tempTimer(2, function()
            print("Step 2: Simulating combat end (in_combat = false)")
            gmcp.Char.CombatStatus = {
                in_combat = false,
                target = "a goblin warrior",  -- Target still there but combat ended
                target_hp_current = 75,
                target_hp_max = 100
            }
            
            -- Trigger the update
            raiseEvent("gmcp.Char.CombatStatus")
            
            tempTimer(0.2, function()
                print("Enemy gauge should now show: 'No Target'")
                print("Please verify the enemy gauge has cleared.\n")
                
                -- Step 3: Resume combat to verify it works again
                tempTimer(2, function()
                    print("Step 3: Resuming combat with new target")
                    gmcp.Char.CombatStatus = {
                        in_combat = true,
                        target = "an orc shaman",
                        target_hp_current = 120,
                        target_hp_max = 150
                    }
                    
                    raiseEvent("gmcp.Char.CombatStatus")
                    
                    tempTimer(0.2, function()
                        print("Enemy gauge should now show: 'an orc shaman: 120/150'")
                        print("\n=== TEST COMPLETE ===")
                        print("If the gauge cleared when combat ended and showed the new target when combat resumed, the test passed!")
                    end)
                end)
            end)
        end)
    end)
end

-- Run the test
print([[
Enemy Gauge Clear Test Loaded!

To run the test, type: lua testEnemyGaugeClear()

The test will:
1. Simulate being in combat with 'a goblin warrior'
2. End combat (in_combat = false) and verify gauge shows 'No Target'
3. Start new combat with 'an orc shaman' to verify gauge works again

Watch your enemy gauge during the test!
]])