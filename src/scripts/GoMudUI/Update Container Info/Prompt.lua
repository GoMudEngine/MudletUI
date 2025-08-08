function ui.updatePromptDisplay()
  -- Cache values with sensible defaults.
  local xp, xptnl = 100, 1000
  local energy, energyMax = 100, 100
  local xpPct, xpPctPretty = 0, 0
  local gold, bank = 0, 0
  local carry, capacity = 0, 0
  --local spell, charge = "", ""

  if gmcp and gmcp.Char and gmcp.Char.Worth then
    local xpInfo = ui.getExperienceInfo()
    xp = xpInfo.current
    xptnl = xpInfo.toNext
    xpPctPretty = xpInfo.percent
    gold  = tonumber(gmcp.Char.Worth.gold_carried) or 0
    bank  = tonumber(gmcp.Char.Worth.gold_bank) or 0
  end
  
  if gmcp and gmcp.Char and gmcp.Char.Vitals then
    energy = tonumber(gmcp.Char.Vitals.energy) or energy
    energyMax = tonumber(gmcp.Char.Vitals.energy_max) or energyMax
  end
  
  if gmcp and gmcp.Char and gmcp.Char.Inventory and gmcp.Char.Inventory.Backpack and gmcp.Char.Inventory.Backpack.Summary then
    local backpack = ui.getBackpackCapacity()
    carry = backpack.count
    capacity = backpack.max
  end

  local promptWidth = ui.mainWindowWidth / ui.consoleFontWidth
  local disp = ui.promptDisplay  -- cache the display reference

  disp:clear()
  --disp:cecho(" <grey>-- <violet>Spell prepared<white>: <DarkSeaGreen>[ ")
  --disp:cechoLink("<u><violet>" .. spell .. "</u>", [[send("t")]], "Use spell", true)
  --disp:cecho("<DarkSeaGreen> ] <grey>")

  --if charge ~= "" then
  --  disp:cecho("<SkyBlue>Charge<white>: <DarkSeaGreen>[ <green>" .. charge)
  --  disp:cecho("<DarkSeaGreen> ] <grey>")
  --end
  

  --local repCount = promptWidth - string.len(spell) - 24
  local repCount = promptWidth
  disp:cecho(string.rep("-", repCount))
  disp:cecho("\n")
  
  disp:cecho(" <DarkSeaGreen>[<white>EN<gold>:<green> " ..
    ui.addNumberSeparator(energy) ..
    "<grey>/<grey>" ..
    ui.addNumberSeparator(energyMax) ..
    "<DarkSeaGreen>] <grey>-")
  
  disp:cecho(" <DarkSeaGreen>[<white>XP<gold>:<green> " ..
    ui.addNumberSeparator(xp) ..
    "<grey>/<grey>" ..
    ui.addNumberSeparator(xptnl) ..
    " <gold>" .. xpPctPretty .. "<white>%<grey> TNL<DarkSeaGreen>] <grey>-")
  
  disp:cecho(" <DarkSeaGreen>[<white>Gold<gold>:<gold> " ..
    ui.addNumberSeparator(gold) ..
    " <white>Bank<gold>:<gold> " ..
    ui.addNumberSeparator(bank) ..
    "<DarkSeaGreen>] <grey>-")
  
  disp:cecho(" <DarkSeaGreen>[<DarkTurquoise>Carry<white>: <grey>" ..
    carry .. "<white>/<grey>" .. capacity ..
    "<DarkSeaGreen>]")
end