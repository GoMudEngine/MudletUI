function ui.updateTopBar()
  -- Check if UI is initialized before trying to update
  if not ui or not ui.topDisplay then
    return
  end
  
  -- Write UI version number in the top bar:
  ui.topDisplay:clear()
  ui.topDisplay:cecho("<DarkSeaGreen>" .. ui.getGameName() .. " UI version<white>: ")
  ui.topDisplay:cechoLink("<SkyBlue><u>"..ui.version.."</u>", [[ui.gomudUIShowFullChangelog()]], "Show the " .. ui.getGameName() .. " UI changelog", true)
  if mmp and mmp.version then
    ui.topDisplay:echo("  ")
    ui.topDisplay:cecho("<DarkSeaGreen>Mapper Version<white>: <SkyBlue>"..mmp.version)
  end
  if ui.crowdmapVersion then
    ui.topDisplay:echo("  ")
    ui.topDisplay:cecho("<DarkSeaGreen>Crowdmap Version<white>: ")
    ui.topDisplay:cechoLink("<SkyBlue><u>"..ui.crowdmapVersion.."</u>", [[mmp.showcrowdchangelog()]],"Show the crowdmap changelog",true)
  end
  
  
  if gmcp.Game and gmcp.Game.Info then
    -- Get the time difference
    -- Prefer login_time_epoch if available, otherwise use login_time
    local loginTimestamp = ui.getLoginTime()
    local timeElapsed = ui.getTimeElapsed(loginTimestamp)

    -- Display the result
    ui.topDisplay:echo("  ")
    ui.topDisplay:cecho("<DarkSeaGreen>Connection Time<white>: <SkyBlue>"..timeElapsed)
  end


end