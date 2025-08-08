function ui.updateCharDisplay()
  -- Extract character info with defaults
  local name = "None"
  local race = "None"
  local class = "None"
  
  if gmcp and gmcp.Char and gmcp.Char.Info then
    name = gmcp.Char.Info.name or "None"
    race = ui.titleCase(gmcp.Char.Info.race) or "None"
    class = ui.titleCase(gmcp.Char.Info.class) or "None"
  end
  
  local alignment = "None"
  local level = 1
  
  if gmcp and gmcp.Char and gmcp.Char.Info then
    alignment = ui.titleCase(gmcp.Char.Info.alignment) or "None"
    level = tonumber(gmcp.Char.Info.level) or 1
  end
  
  -- Clear and update display
  ui.charDisplay:clear("Character")
  
  -- Header with centered formatting
  ui.charDisplay:cecho(
    "Character", 
    fText.fText(
      "<white>[ <gold>Name: <dodger_blue>"..name.."<white> Lvl<gold>: <dodger_blue>"..level.."<white> ]<reset>", 
      {
        alignment = "center",
        formatType = "c",
        width = math.floor(ui.charDisplay:get_width()/ui.consoleFontWidth),
        cap = "",
        spacer = "-",
        inside = true,
        mirror = true
      }
    )
  )
  
  ui.charDisplay:cecho("Character", "\n")
  ui.charDisplay:cecho("Character", "<white>Race<gold>: <grey>"..race.."  <cyan>Class<gold>: <grey>"..class)
  ui.charDisplay:cecho("Character", "\n")
  ui.charDisplay:cecho("Character", "<white>Alignment<gold>: <grey>"..alignment)
  ui.charDisplay:cecho("Character", "\n\n")
  
  -- Stats section (if available)
  if gmcp and gmcp.Char and gmcp.Char.Worth then
    -- Worth points
    ui.charDisplay:cecho(
      "Character",
      "<SeaGreen>Skill Points<white>: <white>"..(gmcp.Char.Worth.skill_points or "0")..
      "  <DodgerBlue>Training Points<white>: <white>"..(gmcp.Char.Worth.training_points or "0")
    )
    ui.charDisplay:cecho("Character", "\n\n")
  end
  
  if gmcp and gmcp.Char and gmcp.Char.Stats then
    -- Stats display (paired for better layout)
    ui.charDisplay:cecho("Character", "<SkyBlue>Mysticism<white>: <gold>"..string.format("%2d", tonumber(gmcp.Char.Stats.mysticism) or 0))
    ui.charDisplay:cecho("Character", "    <SkyBlue>Perception<white>:    <gold>"..string.format("%2d", tonumber(gmcp.Char.Stats.perception) or 0))
    ui.charDisplay:cecho("Character", "\n")
    
    ui.charDisplay:cecho("Character", "<SkyBlue>Smarts<white>:    <gold>"..string.format("%2d", tonumber(gmcp.Char.Stats.smarts) or 0))
    ui.charDisplay:cecho("Character", "    <SkyBlue>Speed<white>:         <gold>"..string.format("%2d", tonumber(gmcp.Char.Stats.speed) or 0))
    ui.charDisplay:cecho("Character", "\n")
    
    ui.charDisplay:cecho("Character", "<SkyBlue>Strength<white>:  <gold>"..string.format("%2d", tonumber(gmcp.Char.Stats.strength) or 0))
    ui.charDisplay:cecho("Character", "    <SkyBlue>Vitality<white>:      <gold>"..string.format("%2d", tonumber(gmcp.Char.Stats.vitality) or 0))
  end
end