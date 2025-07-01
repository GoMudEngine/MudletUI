# GoMudUI Directory Structure Refactoring

## Overview
The codebase has been reorganized from a file-type based structure to a feature/component based structure. This improves maintainability and makes it easier to find related code.

## New Structure

```
src/
├── core/                    # Core functionality loaded first
│   ├── init/               # Initialization (namespace, settings, login handlers)
│   ├── utilities/          # Helper functions
│   ├── config/             # Configuration (styles, themes)
│   ├── infrastructure/     # UI framework (containers, gauges, updates)
│   ├── triggers/           # Core triggers
│   └── aliases/            # Core aliases
├── components/             # Feature-specific displays
│   ├── character/          # Character, who, affects, group displays
│   ├── inventory/          # Equipment, inventory, pets displays
│   ├── communication/      # Channel display
│   ├── combat/             # Combat display, enemy gauge
│   ├── rooms/              # Room display
│   └── ui/                 # UI elements (prompts, top bar, gauges)
├── features/               # Additional features
│   ├── mapper/             # Map exploration, room notes
│   ├── settings/           # Settings display
│   └── ui_gagging/         # Display gagging triggers
└── developer/              # Developer tools (loaded last)
```

## Load Order

The files are loaded in this specific order to handle dependencies (controlled by JSON files):

1. **Core/Init** - Sets up `ui` namespace and basic framework
   - eventHandlers.lua - Defines `ui = ui or {}` and event system
   - uiSettings.lua - Loads settings and external packages (EMCO, fText)
   - installLoginExit.lua - Profile and connection handlers

2. **Core/Utilities** - Helper functions
   - utilityFunctions.lua - Common utilities
   - colorMap.lua - Color utilities

3. **Core/Config** - Configuration
   - styleConfig.lua - Theme and style definitions

4. **Core/Infrastructure** - UI Framework
   - createContainers.lua - Container creation
   - containerFunctions.lua - Container management
   - gaugeManager.lua - Gauge management system
   - createPlayerGauges.lua - Player gauge initialization
   - autoupdater.lua - Auto-update functionality
   - updateAllDisplays.lua - Master update function

5. **Components** - Feature displays (can load in any order within category)
   - Character, Inventory, Communication, Combat, Rooms, UI components

6. **Features** - Additional features
   - Mapper integration, settings display, UI gagging

7. **Developer** - Developer tools (safe to load last)

## Migration Notes

### File Moves
- All files organized by feature/component
- JSON files control the load order, not filename prefixes
- Empty directories removed

### Key Dependencies
- `ui` namespace must be defined before any other files
- EMCO and fText must be loaded before displays
- Style config must load before container creation
- All infrastructure must load before components

### Aliases and Triggers
- Core triggers moved to `src/core/triggers/`
- UI gagging triggers moved to `src/features/ui_gagging/`
- Main UI alias moved to `src/core/aliases/`

## Benefits

1. **Easier Navigation** - Related files are grouped together
2. **Clear Dependencies** - Load order controlled by JSON files
3. **Better Maintainability** - Features are self-contained
4. **Improved Discoverability** - Clear separation of core vs features
5. **Safer Development** - Developer tools isolated from core functionality