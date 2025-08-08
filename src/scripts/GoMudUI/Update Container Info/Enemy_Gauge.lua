function ui.updateEnemyGauge()
  -- Debug: Check if GMCP data exists
  if gmcp.Char == nil then
    ui.enemyGauge:setValue(100,100, f"<center>No GMCP Data</center>")
    ui.enemyLabel:echo("")
    return
  end
  
  if not gmcp.Char.Combat or not gmcp.Char.Combat.Status then
    ui.enemyGauge:setValue(100,100, f"<center>No Combat Status</center>")
    ui.enemyLabel:echo("")
    return
  end
  
  local combat = gmcp.Char.Combat.Status
  local target = gmcp.Char.Combat.Target
  
  -- Check if in combat and has a target
  if combat.in_combat and target and target.name and target.name ~= "" then
    -- Update enemy health
    ui.enemyGauge.front:setStyleSheet(f[[{ui.settings.cssFont} background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(150, 25, 25), stop: 0.1 rgb(180,0,0), stop: 0.85 rgb(155,0,0), stop: 1 rgb(130,0,0));border-radius: 3px;border: 1px solid rgba(160, 160, 160, 50%);]]) 
    
    local hp = tonumber(target.hp_current) or 0
    local maxhp = tonumber(target.hp_max) or 1
    local targetName = tostring(target.name)
    
    -- Always show the enemy name in the gauge
    ui.enemyGauge:setValue(hp, maxhp, f"<center>"..targetName.."</center>")
    
    -- Show HP in the label
    ui.enemyLabel:echo(hp.."/"..maxhp)
  else
    -- Not in combat or no target
    ui.enemyGauge.front:setStyleSheet(f[[{ui.settings.cssFont} background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(100, 25, 25), stop: 0.1 rgb(120,0,0), stop: 0.85 rgb(105,0,0), stop: 1 rgb(80,0,0));border-radius: 3px;border: 1px solid rgba(160, 160, 160, 50%);]])
    ui.enemyGauge:setValue(100,100, f"<center>No Enemy</center>")
    ui.enemyLabel:echo("")
  end
end