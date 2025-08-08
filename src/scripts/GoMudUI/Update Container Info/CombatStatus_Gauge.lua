function ui.updateCombatStatusGauge()
  if gmcp.Char == nil or gmcp.Char.Combat == nil or gmcp.Char.Combat.Cooldown == nil then
    ui.balGauge:setValue(100, 100, f"<center>Ready</center>")
    return
  end
  
  --If gmcp information is available set the values, otherwise use dummy values.
  local cooldown = tonumber(gmcp.Char.Combat.Cooldown.cooldown) or 0
  local maxcooldown = tonumber(gmcp.Char.Combat.Cooldown.max_cooldown) or 0
  local cooldownNameIdle = gmcp.Char.Combat.Cooldown.name_idle or "Ready"
  local cooldownNameActive = gmcp.Char.Combat.Cooldown.name_active or "Combat Round"

  if tonumber(cooldown) ~= 0 then
    -- Update Cooldown
    local cur_cooldown = maxcooldown-cooldown
    -- Format cooldown to always show one decimal place
    local formattedCooldown = string.format("%.1f", cooldown)
    ui.balGauge:setValue(cur_cooldown, maxcooldown, f"<center>"..formattedCooldown.."</center>")
  else
    ui.balGauge:setValue(100, 100, f"<center>"..cooldownNameIdle.."</center>")
    -- Raise an event we can hook into if something needs to happen on regaining readiness
    raiseEvent("ui.charCooldownReady")
  end
end