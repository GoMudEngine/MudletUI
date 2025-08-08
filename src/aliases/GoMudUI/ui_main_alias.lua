local command = string.trim(matches[2])

if command == "" then
  cecho(
  [[<sky_blue>
                        ****    Welcome to the GoMud Mudlet UI    ****
  
  <grey>This is a work in progress, developed by Morquin inspired by Durd of Asteria.
  
  <yellow>Expect things to break! :)
  <grey>
  In the Settings tab, initially found (unless you have moved it) in the lower
  right corner, next to the Map tab you will find a number of UI settings.
  
  <cyan>Commands available now are:
  
  <green> ui                        <grey>Show this screen again
  
  <green> ui note <note>            <grey>Save a note for a room
  <green> ui note clear             <grey>Remove a note from a room
  <green> ui exploration            <grey>Show map exploration
  
  <YellowGreen> ui color                  <grey>Change the color of the tabs in the UI
  <YellowGreen> ui color show             <grey>Show all available colors
  <YellowGreen> ui color activetab        <grey>Change active tab color (click to select)
  <YellowGreen> ui color inactivetab      <grey>Change inactive tab color (click to select)
  
  <OliveDrab> ui check                  <grey>Manually check for a UI update  
  <OliveDrab> ui update layout          <grey>Update layout with font or size changes
  <OliveDrab> ui update ui              <grey>Manually update to newest UI
  <OliveDrab> ui reset settings         <grey>Clear any custom settings, reverting to default
  <OliveDrab> ui reset layout           <grey>Reset the UI back to initial layout
  <OliveDrab> ui containers             <grey>Show and manage all the UI containers
  <OliveDrab> ui debug                  <grey>Show some UI debug info
  <OliveDrab> ui debug gmcp             <grey>Show full GMCP data
  <OliveDrab> ui debug all              <grey>Show comprehensive GMCP structure
  
  <DodgerBlue> ui refresh                <grey>Request a full refresh of all GMCP data
  <DodgerBlue> ui refresh inventory      <grey>Refresh just the inventory data
  ]]
  )

elseif command == "debug" then
  if matches[3] == "gmcp" then
    echo("\n=== Full GMCP Data ===\n")
    display(gmcp)
  elseif matches[3] == "all" then
    ui.debugAllGMCP()
  else
    ui.showDebug()
  end

elseif command == "reset" then
  if matches[3] == "settings" then
    ui.createSettings()
    ui.displayUIMessage("Default settings loaded")
  elseif matches[3] == "layout" then
    ui.createContainers("reset")
    ui.displayUIMessage("Default layout loaded")
  end

elseif command == "exploration" then
  ui.showMapExpLevel()

elseif command == "note" then
  ui.saveRoomNotes(matches[3])

elseif command == "update" then
  if matches[3] == "layout" then
    ui.createContainers("layout_update")
    -- Refresh GMCP data after layout update
    tempTimer(0.5, function() sendGMCP("GMCP SendFullPayload") end)
  end
  if matches[3] == "ui" then
    ui.installGoMudUI()
  end
  
elseif command == "check" then
  ui.manualUpdate = true
  ui.checkForUpdate()

elseif command == "color" then
  -- Pass any additional arguments to the color command handler
  local colorArgs = matches[3] and string.trim(matches[3]) or ""
  ui.colorCommand(colorArgs)

elseif command == "containers" then
  ui.showContainerState()

elseif command == "refresh" then
  if matches[3] == "inventory" then
    sendGMCP("GMCP SendCharInventoryBackpackItems")
    ui.displayUIMessage("Refreshing inventory data...")
  else
    sendGMCP("GMCP SendFullPayload")
    ui.displayUIMessage("Refreshing all GMCP data...")
  end

else
  ui.displayUIMessage("Unknown command option <white>"..command.."<reset>")
end