function ui.updateCombatDisplay()
  if not gmcp.Char or not gmcp.Char.Combat or not gmcp.Char.Combat.Status then
    ui.roomDisplay:clear("Combat")
    ui.roomDisplay:cecho("Combat", "<grey> Not engaged in combat")
    return
  end
  
  local combat = gmcp.Char.Combat.Status
  local target = gmcp.Char.Combat.Target
  
  -- Check if in combat
  if combat.in_combat then
    ui.roomDisplay:switchTab("Combat")
    ui.roomDisplay:clear("Combat")
    
    -- Display primary target from Combat.Target
    if target and target.name and target.name ~= "" then
      ui.roomDisplay:cecho("Combat", "<grey>Primary Target<white>:\n")
      local hp = tonumber(target.hp_current) or 0
      local maxhp = tonumber(target.hp_max) or 1
      ui.roomDisplay:cecho("Combat", "<red>"..target.name..string.rep(" ", 35-string.len(target.name)-string.len(tostring(hp))-string.len(tostring(maxhp))).."<gold>"..hp.."<white>/<gold>"..maxhp.."\n")
    end
    
    -- Check for additional enemies from Combat.Enemies
    local combatEnemies = gmcp.Char.Combat.Enemies
    if combatEnemies and #combatEnemies > 0 then
      ui.roomDisplay:cecho("Combat", "\n<grey>Combat Enemies<white>:\n")
      for k, v in ipairs(combatEnemies) do
        if type(v) == "table" and v.name then
          local enemyName = v.name or "Unknown"
          if v.health and v.health_max then
            local hp = tonumber(v.health) or 0
            local maxhp = tonumber(v.health_max) or 1
            ui.roomDisplay:cecho("Combat", "<red>"..enemyName..string.rep(" ", 35-string.len(enemyName)-string.len(tostring(hp))-string.len(tostring(maxhp))).."<gold>"..hp.."<white>/<gold>"..maxhp.."\n")
          else
            ui.roomDisplay:cecho("Combat", "<red>"..enemyName.."\n")
          end
        elseif type(v) == "string" then
          ui.roomDisplay:cecho("Combat", "<red>"..v.."\n")
        end
      end
    end
    
    -- Show innocent/peaceful actors if available
    if gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.Contents then
      local hasInnocent = false
      
      -- Check NPCs for peaceful/innocent
      if gmcp.Room.Info.Contents.Npcs then
        for k, v in pairs(gmcp.Room.Info.Contents.Npcs) do
          if v.type == "Peaceful" or v.type == "Innocent" then
            if not hasInnocent then
              ui.roomDisplay:cecho("Combat", "\n<grey>Innocent/Peacefuls<white>:\n")
              hasInnocent = true
            end
            ui.roomDisplay:cecho("Combat", "<cyan>"..(v.name or "Unknown").."\n")
          end
        end
      end
    end
  else
    -- Not in combat
    ui.roomDisplay:switchTab("Room")
    ui.roomDisplay:clear("Combat")
    ui.roomDisplay:cecho("Combat", "<grey> Not engaged in combat")
  end
end