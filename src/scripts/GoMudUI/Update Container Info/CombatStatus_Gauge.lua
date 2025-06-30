function ui.updateCombatStatusGauge()
  if gmcp.Char == nil or gmcp.Char.CombatStatus == nil or gmcp.Char.CombatStatus.cooldown == nil then
    ui.balGauge:setValue(100, 100, f"<center>Ready</center>")
    return
  end
  --If gmcp information is availabe set the values, otherwise use dummy values.
  local cooldown = gmcp.Char.CombatStatus.cooldown or 0
  local maxcooldown = gmcp.Char.CombatStatus.max_cooldown or 0
  local cooldownNameIdle = gmcp.Char.CombatStatus.name_idle
  local cooldownNameActive = gmcp.Char.CombatStatus.name_active

  if tonumber(cooldown) ~= 0 then
    -- Update Cooldown
    local cur_cooldown = maxcooldown-cooldown
      --if string.len(tostring(cooldown)) < 2 then
        --ui.balGauge:setValue(cur_cooldown, maxcooldown, f"<center>"..math.floor(cooldown)..".0</center>")
      --else
        ui.balGauge:setValue(cur_cooldown, maxcooldown, f"<center>"..cooldown.."</center>")
      --end
  else
    ui.balGauge:setValue(100, 100, f"<center>"..cooldownNameIdle.."</center>")
    -- Raise an event we can hook into if something needs to happen on regaining readiness
    raiseEvent("ui.charCooldownReady")
  end
end
