-- Define constants and helper functions outside the update function
ui.questStatusColor = ui.questStatusColor
	or {
		Undiscovered = "<red>",
		Discovered = "<orange>",
		Finished = "<green>",
		Unfinished = "<cyan>",
		Started = "<dodger_blue>",
	}

local function getNames(tbl)
	local names = {}
	for _, entry in ipairs(tbl or {}) do
		names[#names + 1] = entry.name
	end
	return table.concat(names, ", ")
end

function ui.updateRoomDisplay()
	if not ui.hasGmcpData("Room", "Info") then
		return
	end

	ui.updateDisplay("roomDisplay", "Room", function(display, tabName)
		-- Get room info with defaults
		local roomNum = ui.getGmcpData("0", "Room", "Info", "num")
		local environment = ui.getGmcpData("Unknown", "Room", "Info", "environment")
		local area = ui.getGmcpData("Unknown Area", "Room", "Info", "area")
		local details = ui.getGmcpData({}, "Room", "Info", "details")
		local quest = ui.getGmcpData(0, "Room", "Info", "quest")
		local questStatus = ui.getGmcpData("Undiscovered", "Room", "Info", "queststatus")
		local questName = ui.getGmcpData("No Quest", "Room", "Info", "questname")

		-- Get room content with defaults
		local adventures = ui.getGmcpData({}, "Room", "Content", "Adventures")
		local npcs = ui.getGmcpData({}, "Room", "Content", "NPC")
		local items = ui.getGmcpData({}, "Room", "Content", "Items")

		-- Build room features string
		local roomFeatures = (#details > 0) and table.concat(details, ", ") or "None"

		-- Display header
		local headerText = string.format("%s - %s", roomNum, environment)
		display:cecho(tabName, ui.createHeader("Room", headerText, display:get_width()) .. "\n")

		-- Display area and features
		local areaName = ui.titleCase(string.gsub(area, "_", " "))
		display:cecho(tabName, "<dodger_blue>Area<white>     : <reset>" .. areaName .. "\n")
		display:cecho(tabName, "<dodger_blue>Features<white> : <reset>" .. roomFeatures .. "\n")

		-- Display quest information
		if quest == 0 then
			display:cecho(tabName, "<dodger_blue>Quest<white>    : <reset>None")
		else
			display:cecho(
				tabName,
				string.format(
					"<dodger_blue>Quest<white>    : <gold>%s <white>(%s%s<white>)\n",
					quest,
					ui.questStatusColor[questStatus],
					questStatus
				)
			)
			display:cecho(tabName, "<dodger_blue>QName<white>    : <reset>")
			display:cechoLink(
				tabName,
				[[<reset>"<u>]] .. questName .. [[</u>"]],
				string.format([[send("journal read %s")]], quest),
				"Read journal entry",
				true
			)
		end
		display:cecho(tabName, "\n\n")

		-- Build and display lists
		local adventureList = getNames(adventures)
		local npcList = getNames(npcs)
		local itemList = getNames(items)

		display:cecho(tabName, "<ForestGreen>Adventurers<white>:<reset> " .. adventureList .. "\n")
		display:cecho(tabName, "<cyan>NPC's <white>:<reset> " .. npcList .. "\n")
		display:cecho(tabName, "<green>Items <white>: <reset>" .. itemList .. "\n\n")

		-- Display personal notes
		display:cecho(tabName, "<DodgerBlue>Personal notes<grey>: ui note <note>")
		local roomNote = ui.roomNotes[roomNum]
		if roomNote then
			display:cecho(tabName, "\n<gold>" .. roomNote.notes)
		end
	end)
end
