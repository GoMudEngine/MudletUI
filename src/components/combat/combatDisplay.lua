function ui.updateCombatDisplay()
	if not ui.hasGmcpData("Char") then
		return
	end

	local enemies = ui.getGmcpData(nil, "Char", "Enemies")

	-- Not in combat
	if not enemies then
		ui.updateDisplay("roomDisplay", "Combat", function(display, tabName)
			display:cecho(tabName, "<grey> Not engaged in combat")
		end)
		return
	end

	-- In combat
	if enemies[1] then
		ui.roomDisplay:switchTab("Combat")
		ui.updateDisplay("roomDisplay", "Combat", function(display, tabName)
			local hostileGuid = {}

			-- Display primary target
			local primaryEnemy = enemies[1]
			if primaryEnemy then
				table.insert(hostileGuid, primaryEnemy.guid)
				display:cecho(tabName, "<grey>Target<white>:\n")

				local nameLength = string.len(primaryEnemy.name)
				local hpLength = string.len(tostring(primaryEnemy.hp))
				local maxHpLength = string.len(tostring(primaryEnemy.maxhp))
				local padding = math.max(1, 35 - nameLength - hpLength - maxHpLength)

				display:cecho(
					tabName,
					string.format(
						"<red>%s%s<gold>%s<white>/<gold>%s\n",
						primaryEnemy.name,
						string.rep(" ", padding),
						primaryEnemy.hp,
						primaryEnemy.maxhp
					)
				)
			end

			-- Display other hostiles
			local hasOtherHostiles = false
			for k, enemy in pairs(enemies) do
				if k > 1 then
					if not hasOtherHostiles then
						display:cecho(tabName, "\n<grey>Hostiles<white>:\n")
						hasOtherHostiles = true
					end

					table.insert(hostileGuid, enemy.guid)
					local nameLength = string.len(enemy.name)
					local hpLength = string.len(tostring(enemy.hp))
					local maxHpLength = string.len(tostring(enemy.maxhp))
					local padding = math.max(1, 35 - nameLength - hpLength - maxHpLength)

					display:cecho(
						tabName,
						string.format(
							"<red>%s%s<gold>%s<white>/<gold>%s\n",
							enemy.name,
							string.rep(" ", padding),
							enemy.hp,
							enemy.maxhp
						)
					)
				end
			end

			-- Display innocents/peacefuls
			local roomActors = ui.getGmcpData({}, "Room", "Actor")
			local hasInnocents = false

			for _, actor in pairs(roomActors) do
				if
					(actor.type == "Peaceful" or actor.type == "Innocent")
					and not table.contains(hostileGuid, actor.guid)
				then
					if not hasInnocents then
						display:cecho(tabName, "\n<grey>Innocent/Peacefuls<white>:\n")
						hasInnocents = true
					end
					display:cecho(tabName, "<cyan>" .. actor.name .. "\n")
				end
			end
		end)
	else
		-- No enemies but combat display requested
		ui.roomDisplay:switchTab("Room")
		ui.updateDisplay("roomDisplay", "Combat", function(display, tabName)
			display:cecho(tabName, "<grey>Target<white>:\n")
			display:cecho(tabName, "<red>none\n")
		end)
	end
end
