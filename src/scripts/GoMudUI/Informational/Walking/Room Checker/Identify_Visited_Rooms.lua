ui.knownRooms = ui.knownRooms or {}

function ui.checkRooms()
  local roomId = ui.getRoomId()
  if not roomId then return end
  if not getRoomArea(roomId) then return end

  local questNum
  local shopName
  local shopExists
  local area = getRoomAreaName(getRoomArea(roomId))
  
  -- Check for quest info
  if gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.Basic and gmcp.Room.Info.Basic.quest and gmcp.Room.Info.Basic.quest ~= 0 then
    questNum = gmcp.Room.Info.Basic.quest
  else
    questNum = false
  end

  -- Check for shop info
  if gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.Basic and gmcp.Room.Info.Basic.shop and gmcp.Room.Info.Basic.shop ~= "" then
    shopName = gmcp.Room.Info.Basic.shop
    shopExists = true
  else
    shopName = ""
    shopExists = false
  end
  
  ui.unHighLightRooms(roomId)
  
  ui.knownRooms[roomId] = ui.knownRooms[roomId] or {}
  
  ui.knownRooms[roomId].area = area
  ui.knownRooms[roomId].quest = questNum
  ui.knownRooms[roomId].shop = shopExists
  ui.knownRooms[roomId].shopName = shopName
    
  -- Check for room contents
  if gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.Contents then
    ui.knownRooms[roomId].contents = ui.knownRooms[roomId].contents or {}
    
    -- Process NPCs
    if gmcp.Room.Info.Contents.Npcs then
      for _, npc in ipairs(gmcp.Room.Info.Contents.Npcs) do
        if npc.name and not table.contains(ui.knownRooms[roomId].contents, npc.name) then
          table.insert(ui.knownRooms[roomId].contents, npc.name)
        end
      end
    end
    
    -- Process Items
    if gmcp.Room.Info.Contents.Items then
      for _, item in ipairs(gmcp.Room.Info.Contents.Items) do
        if item.name and not table.contains(ui.knownRooms[roomId].contents, item.name) then
          table.insert(ui.knownRooms[roomId].contents, item.name)
        end
      end
    end
  end
end

--registerNamedEventHandler("ui","checkVisitedRooms","gmcp.Room",
--  function()
--    ui.checkRooms("walking")
--  end
--)


function ui.clearVisitedRooms()
  for k,_ in pairs(ui.knownRooms) do
    if getRoomChar(k) == "X" then
      echo("Room: "..k.." Char: "..getRoomChar(k).."\n")
      setRoomChar(k,ui.knownRooms[k].roomCharBackup)
      centerview(mmp.currentroom)
    end
  end


end