function ui.saveRoomNotes(note)
  ui.roomNotes = ui.roomNotes or {}
  local roomId = ui.getRoomId()
  
  if not roomId then
    cecho("\n<red>Error: Unable to get current room ID.\n")
    return
  end
  
  if note == "clear" then
    ui.roomNotes[roomId] = nil
    cecho("\n<DodgerBlue>Thank you!\n")
    cecho("\n<DodgerBlue>Room notes saved for room id <green>"..roomId.." <DodgerBlue>have been cleared.\n\n")
  else
    ui.roomNotes[roomId] = {notes = note}
    cecho("\n<DodgerBlue>Thank you!\n")
    cecho("\n<DodgerBlue>Room notes saved for room id <green>"..roomId.."<white>: <gold>"..ui.roomNotes[roomId].notes.."\n\n")
 
  end
 
  -- Save the notes table so we can use it later
  table.save(getMudletHomeDir().."/"..ui.packageName.."/ui.roomNotes.lua", ui.roomNotes)
  
  -- Once the note is saved, reload the room info
  ui.updateRoomDisplay()

end