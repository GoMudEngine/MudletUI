function ui.updatePlayerGauges()
  if gmcp.Char == nil or gmcp.Char.Vitals == nil or gmcp.Char.Vitals.health == nil then
    ui.hpGauge:setValue(100,100, f"<center>100/100</center>")
    ui.spGauge:setValue(100,100, f"<center>100/100</center>")
    return
  end
  
  --If gmcp information is availabe set the values, otherwise use dummy values.
  if gmcp.Char.Vitals then
    hp = tonumber(gmcp.Char.Vitals.health) or 0
    hp_max = tonumber(gmcp.Char.Vitals.health_max) or 0
    sp = tonumber(gmcp.Char.Vitals.spell_points) or 0
    sp_max = tonumber(gmcp.Char.Vitals.spell_points_max) or 0
  
    -- Update health
    ui.hpGauge:setValue(hp, hp_max, f"<center>{hp}/{hp_max}</center>")
    
    -- Update mana
    ui.spGauge:setValue(sp, sp_max, f"<center>{sp}/{sp_max}</center>")
    
  else
    ui.hpGauge:setValue(100,100)
    ui.spGauge:setValue(100,100)
  end

end