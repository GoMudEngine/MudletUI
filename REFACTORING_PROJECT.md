# GoMud UI Refactoring Project

## Overview
This document outlines the refactoring work completed and remaining tasks for improving the GoMud UI codebase structure, maintainability, and consistency.

## Completed Work ✅

### 1. Fixed Filename Typos
- Renamed files with "roms" to "rooms" in Informational/Walking scripts
- Updated corresponding JSON files to match

### 2. Standardized File Naming Conventions
- All Lua files now follow camelCase convention
- Examples of changes:
  - `Color_Map.lua` → `colorMap.lua`
  - `Settings_Handler.lua` → `settingsHandler.lua`
  - `Create_Player_Gauges.lua` → `createPlayerGauges.lua`
  - `CombatStatus_Gauge.lua` → `combatStatusGauge.lua`

### 3. Created Utility Functions
Added new utility functions to `utilityFunctions.lua`:
- **GMCP Validation**:
  - `ui.hasGmcpData(...)` - Checks if nested GMCP path exists
  - `ui.getGmcpData(default, ...)` - Safely gets GMCP data with default value
- **Display Utilities**:
  - `ui.updateDisplay(displayName, tabName, updateFunc)` - Base update function
  - `ui.createHeader(title, subtitle, displayWidth)` - Formatted header creation
  - `ui.displayEcho(display, tabName, content, alignment)` - Consistent display output
  - `ui.getDisplayWidthInChars(display)` - Calculate display width
- **Gauge Utilities**:
  - `ui.createGauge(name, params)` - Factory function for gauge creation
  - `ui.colorByPercent(current, max, value)` - Color formatting based on percentage

### 4. Refactored Key Files
- **character.lua** - Now uses utility functions for GMCP checks and display updates
- **createPlayerGauges.lua** - Reduced from 141 to 112 lines using gauge factory

## Remaining Tasks 📋

### High Priority
#### 1. Migrate Remaining Display Files to Use Utility Functions
**Files to update**:
- `who.lua`
- `inventory.lua`
- `equipment.lua`
- `affects.lua`
- `channels.lua`
- `combat.lua`
- `group.lua`
- `pets.lua`
- `room.lua`

**Example refactoring for who.lua**:
```lua
function ui.updateWhoDisplay()
    if not ui.hasGmcpData("Game", "Who", "Players") then
        return
    end
    
    ui.updateDisplay("charDisplay", "Wholist", function(display, tabName)
        local players = gmcp.Game.Who.Players
        local header = ui.createHeader("Online players", #players, display:get_width())
        
        ui.displayEcho(display, tabName, header .. "\n")
        
        local playerNames = {}
        for _, player in ipairs(players) do
            playerNames[#playerNames + 1] = "<forest_green>" .. player.name
        end
        
        ui.displayEcho(display, tabName, table.concat(playerNames, ", "))
    end)
end
```

### Medium Priority
#### 2. Consolidate Scattered CSS Styles
Create a centralized style configuration to replace hardcoded CSS strings:

**New file**: `styleConfig.lua`
```lua
ui.styles = {
    containers = {
        default = "background-color:rgba(15,15,15,100%);",
        noBorder = "border-bottom: 0px solid rgba(15,15,15,100%);padding-top: 10px;",
        leftBorder = "border-right: 2px solid rgba(40,40,40,100%);",
        topBorder = "border-bottom: 2px solid rgba(40,40,40,100%);",
        rightBorder = "border-left: 2px solid rgba(40,40,40,100%);",
        bottomBorder = "border-top: 2px solid rgba(40,40,40,100%);"
    },
    
    gauges = {
        hp = {
            front = "background-color: QLinearGradient(...)",
            back = "background-color: rgba(15,15,15,100%);",
            text = "color: white; font-weight: bold;"
        }
        -- Add other gauge styles
    },
    
    tabs = {
        active = "color: white; background-color: ${activeTabBGColor};",
        inactive = "color: white; background-color: ${inactiveTabBGColor};"
    }
}
```

#### 3. Create Gauge Management System
Centralize gauge creation and updates:

```lua
ui.gaugeConfigs = {
    player = {
        hp = { color = "hp", position = {x = 10, y = 0} },
        sp = { color = "sp", position = {x = 10, y = 25} },
        ep = { color = "ep", position = {x = 270, y = 0} },
        xp = { color = "xp", position = {x = 270, y = 25} }
    },
    enemy = {
        hp = { color = "enemyHp", width = 190, height = 18 }
    }
}

function ui.createGaugeSet(setName, container)
    local gauges = {}
    local config = ui.gaugeConfigs[setName]
    
    for name, settings in pairs(config) do
        gauges[name] = ui.createGauge(name, {
            name = setName .. "_" .. name,
            x = settings.position.x,
            y = settings.position.y,
            width = settings.width or 250,
            height = settings.height or 18
        }, container)
    end
    
    return gauges
end
```

### Low Priority
#### 4. Add Developer Tools
Create debugging and development utilities:

```lua
-- UI inspector
function ui.inspect(component)
    if component == "all" then
        ui.showComponentTree()
    elseif ui[component] then
        display(ui[component])
    end
end

-- Live reload for development
function ui.reloadDisplay(displayName)
    local file = "Update Container Info/" .. displayName .. ".lua"
    if io.exists(file) then
        dofile(file)
        ui["update" .. displayName:title() .. "Display"]()
        ui.displayUIMessage("Reloaded " .. displayName)
    end
end

-- Performance profiling
function ui.profileUpdate(displayName)
    local start = getStopWatchTime("ui_profile")
    ui["update" .. displayName:title() .. "Display"]()
    local elapsed = getStopWatchTime("ui_profile") - start
    ui.displayUIMessage(displayName .. " update took " .. elapsed .. "ms")
end
```

#### 5. Reorganize Directory Structure by Component
**Current structure** (by type):
```
scripts/GoMudUI/
├── Core Functions/
├── UI Containers/
├── Update Container Info/
└── Informational/
```

**Proposed structure** (by feature):
```
scripts/GoMudUI/
├── Core/
│   ├── utilities.lua
│   ├── settings.lua
│   ├── styles.lua
│   └── autoUpdater.lua
├── Components/
│   ├── Character/
│   │   ├── display.lua
│   │   ├── gauges.lua
│   │   └── update.lua
│   ├── Combat/
│   │   ├── display.lua
│   │   ├── gauges.lua
│   │   └── update.lua
│   └── ...
└── System/
    ├── events.lua
    ├── initialization.lua
    └── devTools.lua
```

## Benefits of Refactoring

1. **Code Reduction**: ~30-50% reduction in display update files
2. **Consistency**: Standardized patterns across all components
3. **Maintainability**: Easier to update and debug
4. **Flexibility**: Centralized configurations make customization simpler
5. **Performance**: Reduced redundant operations
6. **Developer Experience**: Better tools and clearer structure

## Implementation Timeline

1. **Week 1**: Complete utility migrations (High Priority #1)
2. **Week 2**: Consolidate styles and create gauge management (Medium Priority #2-3)
3. **Week 3**: Add developer tools and plan component reorganization (Low Priority #4-5)

## Notes

- All changes maintain backward compatibility
- Function names follow Mudlet's camelCase convention
- All UI functions remain namespaced under `ui` table
- JSON files are updated when renaming script files